# Feuille de route — profil GitHub `mawena`

Ce dépôt sert deux choses : le README affiché sur https://github.com/mawena et le site statique https://mawena.cloud (`index.html`, voir `DEPLOY.md`).

## Phase 1 — Constat (04/11/2026)

- [x] Relever les données actuelles du profil (dépôts, contributions, langages)
- [x] Vérifier les cartes de stats : github-readme-stats (503 `DEPLOYMENT_PAUSED`) et github-profile-trophy (402 `DEPLOYMENT_DISABLED`) sont hors service
- [x] Résumer les dépôts publics récents

## Phase 2 — Cartes de stats auto-hébergées

- [x] Script `scripts/profile_cards.py` (Python, bibliothèque standard seule) qui génère des cartes SVG claires et sombres : chiffres clés, langages, activité sur 12 mois
- [x] Workflow GitHub Actions quotidien qui publie les cartes sur la branche `output` (aucun commit de robot sur `main` ou `develop`)
- [x] Première génération locale et vérification visuelle (clair et sombre)
- [x] Première publication de la branche `output` (faite à la main depuis le poste, le 04/11/2026)
- [ ] Premier passage du workflow sur GitHub Actions : bloqué, « account is locked due to a billing issue » (régler la facturation du compte, puis relancer avec `gh workflow run profile-cards.yml -R mawena/mawena`)

## Phase 3 — Nouveau README du profil

- [x] Accroche et positionnement mis à jour (Laravel/Vue + outils système en Rust, C et Python)
- [x] Projets phares 2026 avec liens (uniquement des dépôts publics)
- [x] Pile technique mise à jour (Rust, C…)
- [x] Remplacer les cartes cassées par les cartes auto-hébergées
- [x] Corriger le lien Maravel (pointait vers le profil au lieu du dépôt)

## Phase 4 — Publication

- [x] Fin de la feature, push de `develop`
- [x] Release git flow 1.0.0 (`main` réconciliée avec `develop`, tag `v1.0.0`)
- [ ] Suggestions hors dépôt : bio du profil, dépôts épinglés, branche par défaut (reprises en phase 5)

## Phase 5 — Mise à jour de novembre (14/11/2026)

- [x] Description, sujets (topics) et site de tous les dépôts publics (25), dont l'« About » du dépôt du profil
- [x] README des dépôts publics vérifiés par rapport au code ; corrigés : Jarvis, maravel, Jideo, lnmp, dnsmasq-webui, fcx-toolkit, immich ; créés : Hardware_store_manager, UCAO-ASD
- [x] Cartes de stats régénérées depuis le poste et publiées sur `output` (GitHub Actions toujours bloqué par la facturation)
- [x] README du profil : chiffres 2026, six projets vedettes avec leur version, nouveaux projets (CCS, Gagarine, Voix-là, Sésame, Canapé, Diapason), « What I bring to a team », appel aux recruteurs et aux contributeurs
- [x] Lien vers le dépôt privé `dbackup` retiré du profil (lien cassé pour les visiteurs)
- [ ] Bio et site web du profil : à coller à la main (le jeton `gh` n'a pas le droit `user`)
- [ ] Épingler six dépôts : CCS, gagarine, Portail, Voix-la, Canape, maravel (pas d'API pour épingler)
- [ ] Régler la facturation du compte GitHub pour que le workflow des cartes reprenne seul
- [x] Mettre le site https://mawena.cloud (`index.html`) au niveau du profil (fait en phase 6)

## Phase 6 — Site mawena.cloud et ménage (14/11/2026)

- [x] Site mawena.cloud : positionnement fullstack et Linux, ouvert aux postes à distance et aux missions, nouveaux projets, chiffres clés, liens GitHub et LinkedIn
- [x] Rendu vérifié sur ordinateur (1366 px) et sur mobile (390 px)
- [x] Racine web du serveur nettoyée : fichiers privés et `.git` sortis du dossier servi (déplacés, rien de supprimé)
- [x] `DEPLOY.md` : déploiement fichier par fichier, sans `.git` ni `--delete` (le dépôt APT `repo/` vit à côté du site)
- [x] fcx-toolkit retiré du profil (dépôt passé en privé)
- [x] Site déployé et vérifié en ligne
- [ ] Nginx (root sur le VPS) : refuser les fichiers cachés sur tous les sites, retirer `autoindex on` du site mawena.cloud
