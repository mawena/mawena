# Déploiement — mawena.cloud

Site 100% statique : `index.html` + `robots.txt` + `sitemap.xml`. Aucun build, aucune dépendance.

## 1. Copier les fichiers sur le serveur

```bash
rsync -avz --delete ./ user@mawena.cloud:/var/www/mawena.cloud/
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
