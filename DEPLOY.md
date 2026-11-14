# Déploiement — mawena.cloud

Site 100% statique : `index.html` + `robots.txt` + `sitemap.xml`. Aucun build, aucune dépendance.

Le reste du dépôt ne part pas sur le serveur : `README.md` est le profil GitHub, `scripts/` et `.github/` génèrent ses cartes de stats, et `.git` ne doit jamais être servi.

## 1. Copier les fichiers sur le serveur

Seuls les fichiers du site partent, nommés un par un. **Jamais de `--delete`** : la racine du site héberge aussi le dépôt
APT `repo/` (lnmp, dnsmasq-webui), qui n'est pas dans ce dépôt. **Jamais de `git clone` ou de `git pull` dans la racine
du site** : le dossier `.git` serait servi à tout le monde.

```bash
# SITE_DEST : alias SSH du serveur (~/.ssh/config, qui porte l'hôte et le port) et racine du site, par exemple
# SITE_DEST=mon-vps:/chemin/vers/mawena.cloud/
rsync -avz index.html robots.txt sitemap.xml google318bc662f5536e4c.html setup_lnmp.sh "$SITE_DEST"
```

Après chaque déploiement, vérifier que rien d'autre n'est servi par erreur :

```bash
for p in .git/HEAD README.md DEPLOY.md; do curl -s -o /dev/null -w "$p %{http_code}\n" https://mawena.cloud/$p; done   # 404 attendu
```

## 2. Config Nginx

```nginx
server {
    listen 80;
    server_name mawena.cloud www.mawena.cloud;
    return 301 https://mawena.cloud$request_uri;
}

server {
    listen 443 ssl http2;
    server_name mawena.cloud;

    root /var/www/mawena.cloud;
    index index.html;

    # Certificats (générés par certbot, étape 3)
    ssl_certificate     /etc/letsencrypt/live/mawena.cloud/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/mawena.cloud/privkey.pem;

    gzip on;
    gzip_types text/html text/css application/javascript image/svg+xml;

    location / {
        try_files $uri $uri/ =404;
    }

    # Ne jamais servir les fichiers cachés (.git, .env…), sauf la validation Let's Encrypt
    location ~ /\.(?!well-known) {
        deny all;
    }
}
```

```bash
sudo ln -s /etc/nginx/sites-available/mawena.cloud /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
```

## 3. HTTPS avec Let's Encrypt

```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d mawena.cloud -d www.mawena.cloud
```

## 4. DNS

Chez le registrar de `mawena.cloud` :

| Type | Nom | Valeur         |
|------|-----|----------------|
| A    | @   | IP du serveur  |
| A    | www | IP du serveur  |

## Après mise en ligne

- Vérifier https://mawena.cloud sur mobile (375px) et desktop.
- Soumettre le sitemap dans Google Search Console (`https://mawena.cloud/sitemap.xml`).
- Tester le partage WhatsApp/LinkedIn (aperçu Open Graph).
