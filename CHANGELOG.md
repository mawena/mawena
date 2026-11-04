# Journal des modifications

Toutes les modifications notables de ce dépôt (profil GitHub `mawena` et site https://mawena.cloud) sont consignées ici.

Le format suit [Keep a Changelog](https://keepachangelog.com/fr/1.1.0/), et le dépôt respecte le
[versionnage sémantique](https://semver.org/lang/fr/).

## [Non publié]

## [1.0.0] - 2026-11-04

Première version publiée.

### Ajouté

- **Cartes de stats auto-hébergées** pour le README du profil, en version claire et sombre :
  - `overview` : contributions sur 12 mois et sur l'année, séries en cours et record, dépôts publics actifs, étoiles ;
  - `languages` : langages pondérés par les commits des 12 derniers mois (dépôts publics seulement) ;
  - `activity` : contributions par mois sur 12 mois.
- `scripts/profile_cards.py` génère ces cartes (Python, bibliothèque standard seule, API GraphQL de GitHub).
- Workflow `.github/workflows/profile-cards.yml` : régénération quotidienne et publication sur la branche
  `output`, en un seul commit réécrit à chaque passage, pour ne jamais commiter sur `main` ou `develop`.
- `ROADMAP.md` (feuille de route) et ce `CHANGELOG.md`.

### Modifié

- **README du profil réécrit** avec les données de novembre 2026 :
  - positionnement : Laravel et Vue.js pour les plateformes métier, Rust, C et Flutter pour les outils système,
    paquets Linux, IA locale ;
  - projets 2026 classés par thème (système et bureau, IA locale, web et Laravel, outils Linux) avec leur pile ;
  - pile technique complétée (Rust, C, Kotlin, Dart, FastAPI, MariaDB, SQLite, Debian…), icônes lisibles en
    mode sombre.
- `DEPLOY.md` : `rsync` exclut `.git`, `.github`, `scripts` et les fichiers Markdown du dépôt.

### Corrigé

- Les cartes github-readme-stats (503 `DEPLOYMENT_PAUSED`) et github-profile-trophy (402 `DEPLOYMENT_DISABLED`),
  hors service, sont remplacées.
- Le lien « Maravel » pointait vers le profil au lieu du dépôt `mawena/maravel`.

[Non publié]: https://github.com/mawena/mawena/compare/v1.0.0...develop
[1.0.0]: https://github.com/mawena/mawena/releases/tag/v1.0.0
