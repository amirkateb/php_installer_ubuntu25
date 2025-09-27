# PHP Installer for Ubuntu 25 (plucky)

**Languages:** [English](./README.en.md) · [فارسی](./README.fa.md) · [العربية](./README.ar.md)

A reliable one-command installer for **PHP 8.2 / 8.3 / 8.4** on **Ubuntu 25.x** — without installing a web server. It handles PPA pinning, GPG keys, full extension set for Laravel/heavy workloads, sensible tuning, and an automatic PECL fallback for `imagick` when needed.

> Looking for full docs? Pick your language above.

---

## Quick Start

```bash
git clone https://github.com/amirkateb/php_installer_ubuntu25.git
cd php_installer_ubuntu25
chmod +x install-php.sh
sudo ./install-php.sh 8.2   # or 8.3 / 8.4
```

**One‑liner:**

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/amirkateb/php_installer_ubuntu25/main/install-php.sh) 8.2
```

## Notes

- Ubuntu 25 ships PHP 8.4 in official repos; 8.2/8.3 are provided via a pinned PPA (`noble`) limited to `php*` packages.
- No Nginx/Apache is installed. Point your web server to the relevant FPM socket (e.g., `/run/php/php8.2-fpm.sock`).

## License

MIT
