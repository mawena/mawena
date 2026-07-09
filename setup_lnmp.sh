#!/bin/bash

# ==============================================================================
# Script de Gestion Avancée LNMP & Certbot (Style WireGuard Setup)
# Déploiement : Ubuntu 22.04 / 24.04 VPS
# ==============================================================================

# Fichiers de suivi d'état et de configuration
STATE_FILE="/var/log/lnmp_install_state"
APPS_REGISTRY="/etc/nginx/lnmp_apps.list"

# Couleurs pour l'interface
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Vérification des privilèges root pour lancer le script
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Erreur : Ce script doit être exécuté en tant que root (sudo).${NC}"
    exit 1
fi

# Récupération de l'utilisateur non-root réel qui a lancé le sudo
REAL_USER=${SUDO_USER:-$(logname 2>/dev/null || echo $USER)}
if [ "$REAL_USER" = "root" ]; then
    # Essayer de trouver un utilisateur standard si exécuté directement en root
    REAL_USER=$(awk -F: '$3>=1000 && $1!="nobody" {print $1; exit}' /etc/passwd)
fi

# Initialiser le registre d'applications s'il n'existe pas
touch "$APPS_REGISTRY"

# ==============================================================================
# FONCTIONS D'INSTALLATION ET DE REPRISE
# ==============================================================================

get_state() {
    if [ -f "$STATE_FILE" ]; then
        cat "$STATE_FILE"
    else
        echo "0"
    fi
}

set_state() {
    echo "$1" > "$STATE_FILE"
}

install_lnmp() {
    local current_step=$(get_state)
    
    echo -e "${BLUE}=== Début de l'installation de la pile LNMP ===${NC}"

    # Étape 1 : Système & ACL (Règle l'erreur du setfacl)
    if [ "$current_step" -le 1 ]; then
        echo -e "${YELLOW}[1/7] Mise à jour du système et installation de 'acl'...${NC}"
        apt-get update -y && apt-get upgrade -y
        apt-get install -y acl software-properties-common curl wget unzip git
        set_state 1
    fi

    # Étape 2 : Nginx
    if [ "$current_step" -le 2 ]; then
        echo -e "${YELLOW}[2/7] Installation de Nginx...${NC}"
        apt-get install -y nginx
        systemctl enable --now nginx
        set_state 2
    fi

    # Étape 3 : MariaDB
    if [ "$current_step" -le 3 ]; then
        echo -e "${YELLOW}[3/7] Installation de MariaDB...${NC}"
        apt-get install -y mariadb-server mariadb-client
        systemctl enable --now mariadb
        set_state 3
    fi

    # Étape 4 : PHP 8.3
    if [ "$current_step" -le 4 ]; then
        echo -e "${YELLOW}[4/7] Configuration du dépôt PHP 8.3 et installation...${NC}"
        add-apt-repository ppa:ondrej/php -y
        apt-get update -y
        apt-get install -y php8.3-fpm php8.3-cli php8.3-mysql php8.3-curl \
        php8.3-xml php8.3-mbstring php8.3-zip php8.3-bcmath php8.3-soap \
        php8.3-intl php8.3-readline php8.3-sqlite3 php8.3-gd php8.3-redis
        systemctl enable --now php8.3-fpm
        set_state 4
    fi

    # Étape 5 : Certbot
    if [ "$current_step" -le 5 ]; then
        echo -e "${YELLOW}[5/7] Installation de Certbot pour les certificats SSL...${NC}"
        apt-get install -y certbot python3-certbot-nginx
        set_state 5
    fi

    # Étape 6 : Groupe de dev & Permissions
    if [ "$current_step" -le 6 ]; then
        echo -e "${YELLOW}[6/7] Configuration du groupe 'webdev' et des permissions...${NC}"
        if ! getent group webdev > /dev/null; then
            groupadd webdev
        fi
        
        if [ ! -z "$REAL_USER" ] && [ "$REAL_USER" != "root" ]; then
            usermod -aG webdev "$REAL_USER"
            echo -e "${GREEN}Utilisateur '$REAL_USER' ajouté au groupe webdev.${NC}"
        fi
        usermod -aG webdev www-data

        mkdir -p /var/www/html
        chown -R www-data:webdev /var/www/html
        find /var/www/html -type d -exec chmod g+s {} \;
        chmod -R 775 /var/www/html
        
        # Application des ACLs (Maintenant fonctionnel car le paquet 'acl' est installé à l'étape 1)
        setfacl -R -d -m g:webdev:rwx /var/www/html
        setfacl -R -d -m u:www-data:rwx /var/www/html
        set_state 6
    fi

    # Étape 7 : Application témoin (Mawena / Flixger)
    if [ "$current_step" -le 7 ]; then
        echo -e "${YELLOW}[7/7] Configuration de l'application initiale...${NC}"
        local initial_app_path="/var/www/html/Mawena/Flixger/public"
        mkdir -p "$initial_app_path"
        
        # Création d'un index de test
        if [ ! -f "$initial_app_path/index.php" ]; then
            echo "<?php echo 'Bienvenue sur Mawena Cloud !'; ?>" > "$initial_app_path/index.php"
            chown www-data:webdev "$initial_app_path/index.php"
        fi

        # Génération du VirtualHost demandé
        cat > /etc/nginx/sites-available/example << 'EOF'
server {
    listen 80;
    server_name .mawena.cloud;
    root /var/www/html/Mawena/Flixger/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.html index.php;
    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF
        if [ ! -f /etc/nginx/sites-enabled/example ]; then
            ln -s /etc/nginx/sites-available/example /etc/nginx/sites-enabled/
        fi
        [ -f /etc/nginx/sites-enabled/default ] && rm /etc/nginx/sites-enabled/default
        
        echo "example:.mawena.cloud:/var/www/html/Mawena/Flixger/public" >> "$APPS_REGISTRY"
        
        systemctl restart nginx
        set_state 7
    fi

    echo -e "${GREEN}=== LNMP Installée et configurée avec succès ! ===${NC}"
    echo -e "${YELLOW}Note : Si votre utilisateur distant vient d'être créé, reconnectez votre SSH pour appliquer le groupe 'webdev'.${NC}"
}

# ==============================================================================
# FONCTIONS DE GESTION DES APPLICATIONS WEB
# ==============================================================================

add_web_app() {
    echo -e "${BLUE}=== Ajouter une nouvelle application Web ===${NC}"
    read -p "Entrez le nom d'identification unique de l'app (ex: api-prod) : " app_id
    app_id=$(echo "$app_id" | tr -d ' ')
    
    if [ -f "/etc/nginx/sites-available/$app_id" ]; then
        echo -e "${RED}Erreur : Une application avec l'identifiant '$app_id' existe déjà.${NC}"
        return
    fi

    read -p "Entrez le nom de domaine complet (ex: app.mawena.cloud) : " domain_name
    read -p "Entrez le chemin absolu du dossier racine web (ex: /var/www/html/MonProjet/public) : " app_path

    # Nettoyage et création du dossier
    mkdir -p "$app_path"
    chown -R www-data:webdev "$app_path"

    # Création du fichier Nginx
    cat > /etc/nginx/sites-available/"$app_id" << EOF
server {
    listen 80;
    server_name $domain_name;
    root $app_path;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.html index.php;
    charset utf-8;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

    ln -s /etc/nginx/sites-available/"$app_id" /etc/nginx/sites-enabled/
    nginx -t && systemctl restart nginx
    
    # Enregistrement dans la liste locale
    echo "$app_id:$domain_name:$app_path" >> "$APPS_REGISTRY"
    echo -e "${GREEN}Application '$app_id' configurée avec succès pour $domain_name.${NC}"

    # Proposition SSL directe
    read -p "Voulez-vous générer immédiatement un certificat SSL Let's Encrypt ? (y/n) : " gen_ssl
    if [[ "$gen_ssl" =~ ^[Yy]$ ]]; then
        add_ssl_cert "$app_id"
    fi
}

list_web_apps() {
    echo -e "${BLUE}=== Liste des applications gérées ===${NC}"
    if [ ! -s "$APPS_REGISTRY" ]; then
        echo "Aucune application enregistrée."
        return
    fi
    echo -e "ID App\t\t| Domaine\t\t| Chemin"
    echo "------------------------------------------------------------------------"
    while IFS=: read -r id domain path; do
        echo -e "${GREEN}$id${NC}\t| $domain\t| $path"
    done < "$APPS_REGISTRY"
}

delete_web_app() {
    echo -e "${BLUE}=== Supprimer une application Web ===${NC}"
    list_web_apps
    echo ""
    read -p "Entrez l'ID de l'application à supprimer : " target_id
    
    if ! grep -q "^$target_id:" "$APPS_REGISTRY"; then
        echo -e "${RED}ID d'application introuvable.${NC}"
        return
    fi

    # Nettoyage Nginx
    rm -f /etc/nginx/sites-enabled/"$target_id"
    rm -f /etc/nginx/sites-available/"$target_id"
    
    # Retrait du registre
    sed -i "/^$target_id:/d" "$APPS_REGISTRY"
    
    systemctl restart nginx
    echo -e "${GREEN}Application '$target_id' retirée des configurations Nginx.${NC}"
    echo -e "${YELLOW}Note : Les fichiers physiques dans /var/www/ n'ont pas été supprimés par sécurité.${NC}"
}

# ==============================================================================
# FONCTIONS GESTION DES CERTIFICATS SSL (CERTBOT)
# ==============================================================================

add_ssl_cert() {
    local target_id=$1
    if [ -z "$target_id" ]; then
        echo -e "${BLUE}=== Ajouter un certificat SSL ===${NC}"
        list_web_apps
        echo ""
        read -p "Entrez l'ID de l'application à sécuriser : " target_id
    fi

    local domain=$(grep "^$target_id:" "$APPS_REGISTRY" | cut -d: -f2)
    if [ -z "$domain" ]; then
        echo -e "${RED}Application introuvable ou invalide.${NC}"
        return
    fi

    echo -e "${YELLOW}Génération du certificat SSL avec Certbot pour $domain...${NC}"
    certbot --nginx -d "$domain" --redirect --agree-tos --non-interactive --register-unsafely-without-email

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Certificat SSL activé avec succès pour $domain ! Envoi HTTPS forcé activé.${NC}"
    else
        echo -e "${RED}Erreur lors de la génération du certificat. Vérifiez vos pointages DNS.${NC}"
    fi
}

remove_ssl_cert() {
    echo -e "${BLUE}=== Retirer un certificat SSL ===${NC}"
    list_web_apps
    echo ""
    read -p "Entrez l'ID de l'application dont vous voulez supprimer le SSL : " target_id

    local domain=$(grep "^$target_id:" "$APPS_REGISTRY" | cut -d: -f2)
    if [ -z "$domain" ]; then
        echo -e "${RED}Application introuvable.${NC}"
        return
    fi

    echo -e "${YELLOW}Suppression du certificat pour $domain...${NC}"
    certbot delete --cert-name "$domain"
    
    echo -e "${YELLOW}Restauration de la configuration HTTP standard pour $target_id...${NC}"
    # Note : Après une suppression sauvage de certbot, il faut s'assurer que Nginx n'écoute plus sur le port 443 manquant
    echo -e "${GREEN}Le certificat a été retiré. Veuillez inspecter /etc/nginx/sites-available/$target_id pour ajuster les blocs d'écoute.${NC}"
    systemctl restart nginx
}

# ==============================================================================
# DESINSTALLATION
# ==============================================================================

uninstall_lnmp() {
    echo -e "${RED}=== DÉSINSTALLATION COMPLÈTE LNMP ===${NC}"
    read -p "Êtes-vous absolument sûr de vouloir tout supprimer (Nginx, MariaDB, PHP, Configurations) ? (y/n) : " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        systemctl stop nginx mariadb php8.3-fpm || true
        apt-get purge -y nginx mariadb-server mariadb-client php8.3* certbot python3-certbot-nginx acl
        apt-get autoremove -y
        rm -f "$STATE_FILE" "$APPS_REGISTRY"
        rm -rf /etc/nginx
        echo -e "${GREEN}Le serveur a été nettoyé de la pile LNMP.${NC}"
    else
        echo "Désinstallation annulée."
    fi
}

# ==============================================================================
# INTERFACE MENU PRINCIPAL
# ==============================================================================

show_menu() {
    clear
    echo -e "${BLUE}=====================================================${NC}"
    echo -e "${GREEN}             GESTIONNAIRE LNMP AUTOMATIQUE            ${NC}"
    echo -e "${BLUE}=====================================================${NC}"
    
    local state=$(get_state)
    if [ "$state" -gt 0 ] && [ "$state" -lt 7 ]; then
        echo -e "${YELLOW}   [!] Une installation précédente a coupé à l'étape $state/7.${NC}"
        echo -e "${YELLOW}       L'option 1 reprendra là où elle s'est arrêtée.${NC}"
        echo -e "${BLUE}=====================================================${NC}"
    fi

    echo -e " 1 - Installer / Reprendre l'installation LNMP"
    echo -e " 2 - Lister les applications web"
    echo -e " 3 - Ajouter une application web"
    echo -e " 4 - Supprimer des applications web"
    echo -e " 5 - Ajouter un certificat SSL à une application"
    echo -e " 6 - Retirer un certificat SSL à une application"
    echo -e " 7 - Désinstaller complètement LNMP"
    echo -e " 0 - Quitter"
    echo -e "${BLUE}=====================================================${NC}"
    read -p "Choisissez une option [0-7] : " choice

    case $choice in
        1) install_lnmp ;;
        2) list_web_apps ;;
        3) add_web_app ;;
        4) delete_web_app ;;
        5) add_ssl_cert ;;
        6) remove_ssl_cert ;;
        7) uninstall_lnmp ;;
        0) exit 0 ;;
        *) echo -e "${RED}Option invalide.${NC}" ;;
    esac
    
    echo -e "\nAppuyez sur une touche pour revenir au menu..."
    read -n 1
    show_menu
}

# Lancement du menu interactif
show_menu