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
- [ ] Release git flow (`main`, `develop`, tag)
- [ ] Suggestions hors dépôt : bio du profil, dépôts épinglés, branche par défaut
