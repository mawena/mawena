<h1 align="center">Hi 👋, I'm Charles GAMLIGO <sub>aka <b>mawena</b></sub></h1>

<h3 align="center">Fullstack & systems developer · Lomé, Togo 🇹🇬</h3>

<p align="center">
  <b>Laravel & Vue.js</b> for business platforms · <b>Rust, C & Flutter</b> for tools that run close to the system · <b>Linux packaging</b> and <b>local AI</b>
</p>

<p align="center">
  I build web platforms for businesses (REST APIs, back-offices, credit and reporting workflows), and on the side, the tools I wish existed: an Android file manager that opens encrypted drives, a native git client, a portable filesystem, an offline voice assistant. Self-taught, design-minded, and I ship: versioned releases, <code>.deb</code> packages and my own APT repository.
</p>

<p align="center">
  <a href="https://mawena.cloud"><img src="https://img.shields.io/badge/Portfolio-mawena.cloud-1a7f37?style=for-the-badge&logo=googlechrome&logoColor=white" alt="Portfolio" /></a>
  <a href="mailto:gamligocharles@gmail.com"><img src="https://img.shields.io/badge/Email-gamligocharles%40gmail.com-EA4335?style=for-the-badge&logo=gmail&logoColor=white" alt="Email" /></a>
  <a href="https://wa.me/22891611135"><img src="https://img.shields.io/badge/WhatsApp-Let's_talk-25D366?style=for-the-badge&logo=whatsapp&logoColor=white" alt="WhatsApp" /></a>
</p>

<p align="center"><img src="https://komarev.com/ghpvc/?username=mawena&label=Profile%20views&color=1a7f37&style=flat" alt="Profile views" /></p>

---

### 🛠️ What I'm building in 2026

**Systems & desktop**

| Project | What it does | Stack |
|---|---|---|
| [**Portail**](https://github.com/mawena/Portail) | Android file manager that opens LUKS-encrypted USB drives **without root**: ext4, NTFS, exFAT, SFTP, encrypted vaults. My biggest project, 500+ commits this year. APK on each release. | Flutter · Kotlin · C (lwext4, mbedTLS) |
| [**dada**](https://github.com/mawena/dada) | Portable filesystem for USB drives, read/write on Linux, macOS and Windows, with its own spec, a journal, CRC32C checksums and fuzzing. | Rust · FUSE · WinFsp |
| [**GiGit**](https://github.com/mawena/GiGit) | Fast native desktop git client, inspired by ungit. `.deb` on each release. | Rust · egui |

**Local AI**

| Project | What it does | Stack |
|---|---|---|
| [**Jarvis**](https://github.com/mawena/Jarvis) | Offline French voice assistant for the desktop: wake word, speaker check, control of media, apps and the web. | Rust · whisper · sherpa-onnx · Piper |
| [**Atelier**](https://github.com/mawena/Atelier) | One binary that installs self-hosted open LLMs behind an OpenAI-compatible, key-secured API. Static builds for x86_64 and aarch64. | Rust · Docker · Ollama / vLLM |
| [**Voix-là**](https://github.com/mawena/Voix-la) | Re-voices a song or a talk with a cloned voice. The heavy lifting runs on free Kaggle GPUs. | Python · Seed-VC · Whisper |

**Web & Laravel**

| Project | What it does | Stack |
|---|---|---|
| [**Maravel**](https://github.com/mawena/maravel) <br><a href="https://packagist.org/packages/mawena/maravel"><img src="https://img.shields.io/packagist/v/mawena/maravel?style=flat&label=packagist&color=1a7f37" alt="Packagist" /></a> | Laravel library for REST APIs: generic CRUD controller, database-driven roles & permissions, auto-wired policies, advanced filters, Artisan generators. The base of my Laravel apps. | PHP 8.1–8.4 · Laravel 10–13 |
| [**Pulse**](https://github.com/mawena/pulse) | Live monitoring cockpit for Ubuntu VPS: metrics over WebSocket, processes, services, audit. [Live demo →](https://pulse.mawena.cloud) | Laravel 13 · Vue 3 · Reverb |

**Linux tooling** · installable with `apt` from my own repository, [mawena.cloud/repo](https://mawena.cloud/repo)

| Project | What it does | Stack |
|---|---|---|
| [**lnmp**](https://github.com/mawena/lnmp) | Installs and runs an Nginx + MariaDB + PHP + Certbot stack on Ubuntu, from the command line or a web panel. | Bash · Python |
| [**dnsmasq-webui**](https://github.com/mawena/dnsmasq-webui) | Turns a box into a LAN DNS/DHCP server with a web admin panel. | PHP · dnsmasq |
| [**dbbackup**](https://github.com/mawena/dbackup) | MySQL/MariaDB backups to a remote VPS over rsync and SSH, with rotation and a systemd timer. | Bash · systemd |

**Just for fun:** [**MawCraft**](https://github.com/mawena/MawCraft), a voxel sandbox in the browser with an infinite seeded world, touch controls and multiplayer (Three.js + WebSocket).

### 📊 By the numbers

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/mawena/mawena/output/overview-dark.svg" />
  <img src="https://raw.githubusercontent.com/mawena/mawena/output/overview-light.svg" width="100%" alt="GitHub overview: contributions over the last 12 months and this year, streaks, active public repositories, stars" />
</picture>

<p>
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/mawena/mawena/output/languages-dark.svg" />
    <img src="https://raw.githubusercontent.com/mawena/mawena/output/languages-light.svg" width="49%" alt="Languages, weighted by my commits over the last 12 months" />
  </picture>
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/mawena/mawena/output/activity-dark.svg" />
    <img src="https://raw.githubusercontent.com/mawena/mawena/output/activity-light.svg" width="49%" alt="Contributions per month over the last 12 months" />
  </picture>
</p>

<sub>Refreshed every day by this repository's own GitHub Action (<a href="https://github.com/mawena/mawena/blob/HEAD/scripts/profile_cards.py"><code>scripts/profile_cards.py</code></a>), from public profile data.</sub>

### 🧰 Stack

<p align="left">
<b>Web</b>&nbsp;
<img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/laravel/laravel-original.svg" alt="Laravel" title="Laravel" width="36" height="36"/>
<img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/php/php-original.svg" alt="PHP" title="PHP" width="36" height="36"/>
<img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/vuejs/vuejs-original.svg" alt="Vue.js" title="Vue.js" width="36" height="36"/>
<img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/vuetify/vuetify-original.svg" alt="Vuetify" title="Vuetify" width="36" height="36"/>
<img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/tailwindcss/tailwindcss-original.svg" alt="Tailwind CSS" title="Tailwind CSS" width="36" height="36"/>
<img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/threejs/threejs-original.svg" alt="Three.js" title="Three.js" width="36" height="36"/>
</p>

<p align="left">
<b>Systems & mobile</b>&nbsp;
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://cdn.simpleicons.org/rust/ffffff" />
  <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/rust/rust-original.svg" alt="Rust" title="Rust" width="36" height="36"/>
</picture>
<img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/c/c-original.svg" alt="C" title="C" width="36" height="36"/>
<img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/kotlin/kotlin-original.svg" alt="Kotlin" title="Kotlin" width="36" height="36"/>
<img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/flutter/flutter-original.svg" alt="Flutter" title="Flutter" width="36" height="36"/>
<img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/dart/dart-original.svg" alt="Dart" title="Dart" width="36" height="36"/>
<img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/python/python-original.svg" alt="Python" title="Python" width="36" height="36"/>
<img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/fastapi/fastapi-original.svg" alt="FastAPI" title="FastAPI" width="36" height="36"/>
</p>

<p align="left">
<b>Data & ops</b>&nbsp;
<img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/mariadb/mariadb-original.svg" alt="MariaDB" title="MariaDB" width="36" height="36"/>
<img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/mysql/mysql-original.svg" alt="MySQL" title="MySQL" width="36" height="36"/>
<img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/sqlite/sqlite-original.svg" alt="SQLite" title="SQLite" width="36" height="36"/>
<img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/redis/redis-original.svg" alt="Redis" title="Redis" width="36" height="36"/>
<img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/docker/docker-original.svg" alt="Docker" title="Docker" width="36" height="36"/>
<img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/nginx/nginx-original.svg" alt="Nginx" title="Nginx" width="36" height="36"/>
<img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/debian/debian-original.svg" alt="Debian packaging" title="Debian packaging" width="36" height="36"/>
<img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/ubuntu/ubuntu-original.svg" alt="Ubuntu" title="Ubuntu" width="36" height="36"/>
<img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/bash/bash-original.svg" alt="Bash" title="Bash" width="36" height="36"/>
<img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/git/git-original.svg" alt="Git" title="Git" width="36" height="36"/>
</p>

### 💼 Work with me

- **Open to freelance work and collaborations:** SaaS, business platforms, REST APIs, back-offices, process automation, Linux servers. See [mawena.cloud](https://mawena.cloud).
- 📫 **gamligocharles@gmail.com**, replies within 24h, in French or English.

### 🌐 Connect

<p align="left">
<a href="https://www.linkedin.com/in/charles-gamligo-54a339187" target="blank"><img align="center" src="https://raw.githubusercontent.com/rahuldkjain/github-profile-readme-generator/master/src/images/icons/Social/linked-in-alt.svg" alt="LinkedIn" height="30" width="40" /></a>
<a href="https://twitter.com/DieuGamligo" target="blank"><img align="center" src="https://raw.githubusercontent.com/rahuldkjain/github-profile-readme-generator/master/src/images/icons/Social/twitter.svg" alt="X (Twitter)" height="30" width="40" /></a>
<a href="https://www.facebook.com/charles.gamligo" target="blank"><img align="center" src="https://raw.githubusercontent.com/rahuldkjain/github-profile-readme-generator/master/src/images/icons/Social/facebook.svg" alt="Facebook" height="30" width="40" /></a>
</p>

---

<p align="center"><i>💡 Have a project in mind? Let's talk → <a href="https://mawena.cloud">mawena.cloud</a></i></p>
