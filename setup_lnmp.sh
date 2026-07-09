#!/bin/bash

# ==============================================================================
# Script d'installation automatique LNMP (Linux, Nginx, MariaDB, PHP) sur Ubuntu
# Optimisé pour : Laravel / Vue.js (Mawena Cloud)
# Déploiement : VPS vierge (Ubuntu 22.04 / 24.04)
# ==============================================================================

# Arrêt du script en cas d'erreur
set -e

# Couleurs pour l'affichage
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' 

echo -e "${BLUE}=== Début de l'installation de la pile LNMP ===${NC}"

# 1. Mise à jour des paquets système
echo -e "${YELLOW}[1/6] Mise à jour du système...${NC}"
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -y && sudo apt-get upgrade -y

# 2. Installation de Nginx
echo -e "${YELLOW}[2/6] Installation de Nginx...${NC}"
sudo apt-get install nginx -y
sudo systemctl enable --now nginx

# 3. Installation de MariaDB (Alternative robuste à MySQL)
echo -e "${YELLOW}[3/6] Installation de MariaDB Server...${NC}"
sudo apt-get install mariadb-server mariadb-client -y
sudo systemctl enable --now mariadb

# 4. Installation de PHP 8.3 et des extensions requises
echo -e "${YELLOW}[4/6] Installation de PHP 8.3 et des extensions nécessaires...${NC}"
sudo apt-get install software-properties-common -y
sudo add-apt-repository ppa:ondrej/php -y
sudo apt-get update -y

sudo apt-get install -y php8.3-fpm php8.3-cli php8.3-mysql php8.3-curl \
php8.3-xml php8.3-mbstring php8.3-zip php8.3-bcmath php8.3-soap \
php8.3-intl php8.3-readline php8.3-sqlite3 php8.3-gd php8.3-redis unzip

sudo systemctl enable --now php8.3-fpm

# 5. Configuration des droits d'accès (/var/www/html) et groupe webdev
echo -e "${YELLOW}[5/6] Configuration des utilisateurs et des permissions...${NC}"

# Récupération de l'utilisateur non-root qui exécute le script via sudo
CURRENT_USER=${SUDO_USER:-$(whoami)}

# Création du groupe webdev s'il n'existe pas
if ! getent group webdev > /dev/null; then
    sudo groupadd webdev
    echo -e "${GREEN}Groupe webdev créé.${NC}"
fi

# Ajout de l'utilisateur courant et de www-data au groupe webdev
sudo usermod -aG webdev $CURRENT_USER
sudo usermod -aG webdev www-data

# Création du dossier racine de l'application si inexistant
sudo mkdir -p /var/www/html/Mawena/Flixger/public

# Attribution de la propriété à www-data:webdev
sudo chown -R www-data:webdev /var/www/html

# Configuration du bit SGID pour l'héritage du groupe sur les futurs fichiers/dossiers
sudo find /var/www/html -type d -exec chmod g+s {} \;

# Définition des permissions par défaut (775 pour dossiers, 664 pour fichiers)
sudo chmod -R 775 /var/www/html

# Configuration des ACL par défaut pour maintenir les droits d'écriture
if command -v setfacl &> /dev/null; then
    sudo setfacl -R -d -m g:webdev:rwx /var/www/html
    sudo setfacl -R -d -m u:www-data:rwx /var/www/html
fi

# 6. Configuration du bloc de serveur Nginx (VirtualHost)
echo -e "${YELLOW}[6/6] Configuration du VirtualHost Nginx...${NC}"

NGINX_CONF="/etc/nginx/sites-available/example"

sudo bash -c "cat > $NGINX_CONF" << 'EOF'
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

# Activation de la configuration
if [ ! -f /etc/nginx/sites-enabled/example ]; then
    sudo ln -s /etc/nginx/sites-available/example /etc/nginx/sites-enabled/
fi

# Suppression du VirtualHost par défaut pour éviter les conflits
if [ -f /etc/nginx/sites-enabled/default ]; then
    sudo rm /etc/nginx/sites-enabled/default
fi

# Test et redémarrage de Nginx
sudo nginx -t
sudo systemctl restart nginx

echo -e "${GREEN}=== Installation et configuration terminées avec succès ! ===${NC}"
echo -e "${BLUE}Informations importantes :${NC}"
echo -e " - Racine web de votre projet : /var/www/html/Mawena/Flixger/public"
echo -e " - Configuration Nginx créée dans : $NGINX_CONF"
echo -e " - Membres du groupe webdev : $CURRENT_USER, www-data"
echo -e "${YELLOW}NOTE : Pour appliquer l'ajout de votre utilisateur au groupe webdev, déconnectez-vous et reconnectez-vous à votre session SSH.${NC}"