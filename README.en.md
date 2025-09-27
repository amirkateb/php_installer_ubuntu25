# PHP Installer for Ubuntu 25 (plucky)

A robust one-command installer for **PHP 8.2 / 8.3 / 8.4** on **Ubuntu 25.x**.  
No web server is installed (no Nginx/Apache) — you get PHP CLI & FPM plus a complete set of extensions tuned for Laravel and heavy workloads.

## Why this script?
Ubuntu 25 ships PHP 8.4 in the official repos. For 8.2/8.3, the community PPA (ondrej/php) only targets LTS suites. This script safely **pins that PPA to `noble`** and **imports the correct GPG keys**, so only `php*` packages are pulled while the rest of your system stays on plucky.  
It also auto-fixes the frequent `imagick` dependency gap by building it from **PECL** when distro packages are unavailable.

## Features
- Installs **PHP 8.2 / 8.3 / 8.4** side-by-side (default: 8.4)
- CLI + FPM + dev headers and broad extensions: `curl, zip, mbstring, xml, intl, gd, bcmath, gmp, sqlite3, mysql, pgsql, soap, redis, memcached, opcache`
- Handles **GPG keys** and **APT pinning** (PPA → noble, limited to `php*`)
- Sensible performance tuning (Opcache, JIT, memory limits, realpath cache)
- Auto-builds `imagick` from PECL if `php<V>-imagick` can’t be installed
- Registers **update-alternatives** for `php`, `phpize`, `php-config`

## Quick start
```bash
git clone https://github.com/amirkateb/php_installer_ubuntu25.git
cd php_installer_ubuntu25
chmod +x install-php.sh
sudo ./install-php.sh 8.2   # or 8.3 / 8.4
```

One-liner:
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/amirkateb/php_installer_ubuntu25/main/install-php.sh) 8.2
```

## Usage
```bash
sudo ./install-php.sh <version>
# <version> = 8.2 | 8.3 | 8.4   (default: 8.4)
```

Examples:
```bash
sudo ./install-php.sh 8.2
php -v
systemctl status php8.2-fpm --no-pager
```

Switch default CLI later:
```bash
sudo update-alternatives --config php
sudo update-alternatives --config phpize
sudo update-alternatives --config php-config
```

## What it installs
- Packages:
  - `php<V>, php<V>-cli, php<V>-fpm, php<V>-dev, php<V>-common, php<V>-opcache, php<V>-readline`
  - `php<V>-curl, php<V>-zip, php<V>-mbstring, php<V>-xml, php<V>-intl, php<V>-gd`
  - `php<V>-bcmath, php<V>-gmp, php<V>-sqlite3, php<V>-mysql, php<V>-pgsql, php<V>-soap`
  - `php<V>-redis, php<V>-memcached`
  - `php<V>-imagick` (or **PECL imagick** fallback)
- Tuning file: `/etc/php/<V>/fpm/conf.d/99-laravel.ini` (copied to CLI)
  - `memory_limit=1024M`, `opcache.memory_consumption=256`, `opcache.max_accelerated_files=100000`, JIT enabled, etc.

## Not included
- No web server (Nginx/Apache). Point your server to:
  - `/run/php/php8.2-fpm.sock`, `/run/php/php8.3-fpm.sock`, `/run/php/php8.4-fpm.sock`

## Troubleshooting
- **Repo “not signed” / NO_PUBKEY**: the script writes both PPA keys to `/etc/apt/keyrings/ondrej-php.gpg`.
- **PPA 404 (plucky)**: the script disables plucky entries and creates a **noble** source, pinned to `php*` only.
- **`php8.2-imagick` dependencies missing**: PECL build is attempted and enabled automatically.
- **`php -v` still old**: check path shadowing:
  ```bash
  type -a php
  which php
  readlink -f /usr/bin/php
  ```
  Remove or rename `/usr/local/bin/php` or `/snap/bin/php` if they shadow `/usr/bin/php`.

## Uninstall
```bash
sudo apt remove --purge 'php8.2*' 'php8.3*' 'php8.4*'
sudo rm -f /etc/apt/sources.list.d/ondrej-php-noble.sources
sudo rm -f /etc/apt/preferences.d/ondrej-php
sudo apt autoremove -y
```

## Requirements
Ubuntu 25.x (plucky), sudo privileges, internet.

## License
MIT — see `LICENSE`.
