#!/usr/bin/env bash
set -euo pipefail
[ "$(id -u)" -ne 0 ] && exec sudo -E bash "$0" "$@"
PHPVER="${1:-8.4}"
case "$PHPVER" in 8.2|8.3|8.4) ;; *) echo "use: $0 {8.2|8.3|8.4}"; exit 1;; esac
export DEBIAN_FRONTEND=noninteractive
apt update
apt install -y software-properties-common ca-certificates lsb-release curl unzip gnupg
pkg() { apt-cache policy "$1" | awk -F': ' '/Candidate:/ {print $2}'; }
if [ "$(pkg php${PHPVER}-cli)" = "(none)" ]; then
  mkdir -p /etc/apt/keyrings
  curl -fsSL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x71DAEAAB4AD4CAB6" | gpg --dearmor > /etc/apt/keyrings/ondrej-php-a.gpg
  curl -fsSL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x4F4EA0AAE5267A6C" | gpg --dearmor > /etc/apt/keyrings/ondrej-php-b.gpg
  cat /etc/apt/keyrings/ondrej-php-a.gpg /etc/apt/keyrings/ondrej-php-b.gpg > /etc/apt/keyrings/ondrej-php.gpg
  chmod 0644 /etc/apt/keyrings/ondrej-php.gpg
  rm -f /etc/apt/keyrings/ondrej-php-a.gpg /etc/apt/keyrings/ondrej-php-b.gpg
  shopt -s nullglob
  for f in /etc/apt/sources.list.d/*ondrej*php*; do mv "$f" "$f.disabled" 2>/dev/null || true; done
  cat >/etc/apt/sources.list.d/ondrej-php-noble.sources <<'EOF'
Types: deb
URIs: https://ppa.launchpadcontent.net/ondrej/php/ubuntu
Suites: noble
Components: main
Signed-By: /etc/apt/keyrings/ondrej-php.gpg
EOF
  cat >/etc/apt/preferences.d/ondrej-php <<'EOF'
Package: php*
Pin: release n=noble
Pin-Priority: 900

Package: *
Pin: release n=noble
Pin-Priority: -10
EOF
  apt update
fi
if [ "$(pkg php${PHPVER}-cli)" = "(none)" ]; then echo "php${PHPVER} candidate not found"; exit 1; fi
PKGS_BASE="php${PHPVER} php${PHPVER}-cli php${PHPVER}-fpm php${PHPVER}-dev php${PHPVER}-common php${PHPVER}-opcache php${PHPVER}-readline php${PHPVER}-curl php${PHPVER}-zip php${PHPVER}-mbstring php${PHPVER}-xml php${PHPVER}-intl php${PHPVER}-gd php${PHPVER}-bcmath php${PHPVER}-gmp php${PHPVER}-sqlite3 php${PHPVER}-mysql php${PHPVER}-pgsql php${PHPVER}-soap php${PHPVER}-redis php${PHPVER}-memcached"
apt install -y $PKGS_BASE || true
set +e
apt install -y php${PHPVER}-imagick
IMAGICK_APT_RC=$?
set -e
prio="$(printf '%s' "$PHPVER" | tr -d '.')"
update-alternatives --install /usr/bin/php php /usr/bin/php${PHPVER} ${prio}
update-alternatives --install /usr/bin/phpize phpize /usr/bin/phpize${PHPVER} ${prio}
update-alternatives --install /usr/bin/php-config php-config /usr/bin/php-config${PHPVER} ${prio}
update-alternatives --set php /usr/bin/php${PHPVER} || true
update-alternatives --set phpize /usr/bin/phpize${PHPVER} || true
update-alternatives --set php-config /usr/bin/php-config${PHPVER} || true
TZSTR="$(tr -d '\n' </etc/timezone 2>/dev/null || echo UTC)"
mkdir -p /etc/php/${PHPVER}/fpm/conf.d /etc/php/${PHPVER}/cli/conf.d
cat >/etc/php/${PHPVER}/fpm/conf.d/99-laravel.ini <<INI
memory_limit=1024M
upload_max_filesize=128M
post_max_size=128M
max_execution_time=120
max_input_vars=5000
date.timezone=${TZSTR}
opcache.enable=1
opcache.enable_cli=1
opcache.memory_consumption=256
opcache.max_accelerated_files=100000
opcache.interned_strings_buffer=32
opcache.validate_timestamps=1
opcache.revalidate_freq=2
opcache.jit=1205
opcache.jit_buffer_size=64M
realpath_cache_size=4096k
realpath_cache_ttl=600
INI
cp /etc/php/${PHPVER}/fpm/conf.d/99-laravel.ini /etc/php/${PHPVER}/cli/conf.d/99-laravel.ini
if [ "$IMAGICK_APT_RC" -ne 0 ]; then
  apt install -y imagemagick libmagickwand-dev php-pear
  update-alternatives --set phpize /usr/bin/phpize${PHPVER} || true
  printf "\n" | pecl install -f imagick
  echo "extension=imagick.so" >/etc/php/${PHPVER}/mods-available/imagick.ini
  phpenmod -v ${PHPVER} imagick
fi
systemctl enable --now php${PHPVER}-fpm || true
systemctl restart php${PHPVER}-fpm || true
php -v
php -m | grep -E "^imagick$" || true
systemctl status php${PHPVER}-fpm --no-pager || true
echo "OK: PHP ${PHPVER}"
