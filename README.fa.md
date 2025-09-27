# نصب‌کنندهٔ PHP برای اوبونتو ۲۵ (plucky)

نصب یک‌مرحله‌ای **PHP 8.2 / 8.3 / 8.4** روی **Ubuntu 25.x**.  
وب‌سرور نصب نمی‌شود (نه Nginx و نه Apache)؛ فقط PHP (CLI و FPM) به همراه اکستنشن‌های کامل و تیون‌شده برای لاراول و پروژه‌های سنگین نصب می‌گردد.

## چرا این اسکریپت؟
در اوبونتو ۲۵، PHP 8.4 به‌صورت رسمی در مخازن وجود دارد. برای نسخه‌های ۸.۲/۸.۳ باید از PPA استفاده شود، اما PPA فقط LTS را پشتیبانی می‌کند. این اسکریپت به‌صورت امن **PPA را روی `noble` پین می‌کند** و **کلیدهای GPG** را اضافه می‌کند تا فقط بسته‌های `php*` دریافت شوند و بقیهٔ سیستم روی plucky بماند.  
همچنین اگر `php*-imagick` به دلیل وابستگی‌های ImageMagick نصب نشود، به‌صورت خودکار از **PECL** کامپایل و فعال می‌شود.

## امکانات
- نصب هم‌زمان **PHP 8.2 / 8.3 / 8.4** (پیش‌فرض: 8.4)
- نصب CLI و FPM و dev headers به‌همراه اکستنشن‌های پرکاربرد: `curl, zip, mbstring, xml, intl, gd, bcmath, gmp, sqlite3, mysql, pgsql, soap, redis, memcached, opcache`
- مدیریت خودکار **کلیدهای GPG** و **پین‌کردن APT** (PPA → noble و محدود به `php*`)
- تنظیمات کارایی (Opcache, JIT, memory_limit, realpath_cache)
- ساخت خودکار `imagick` از PECL در صورت نبود بستهٔ سازگار
- ثبت **update-alternatives** برای `php`, `phpize`, `php-config`

## شروع سریع
```bash
git clone https://github.com/amirkateb/php_installer_ubuntu25.git
cd php_installer_ubuntu25
chmod +x install-php.sh
sudo ./install-php.sh 8.2   # یا 8.3 / 8.4
```

اجرای تک‌خطی:
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/amirkateb/php_installer_ubuntu25/main/install-php.sh) 8.2
```

## نحوهٔ استفاده
```bash
sudo ./install-php.sh <version>
# <version> = 8.2 | 8.3 | 8.4   (پیش‌فرض: 8.4)
```

نمونه‌ها:
```bash
sudo ./install-php.sh 8.2
php -v
systemctl status php8.2-fpm --no-pager
```

تغییر نسخهٔ پیش‌فرض CLI:
```bash
sudo update-alternatives --config php
sudo update-alternatives --config phpize
sudo update-alternatives --config php-config
```

## چه چیزهایی نصب می‌شود؟
- پکیج‌ها:
  - `php<V>, php<V>-cli, php<V>-fpm, php<V>-dev, php<V>-common, php<V>-opcache, php<V>-readline`
  - `php<V>-curl, php<V>-zip, php<V>-mbstring, php<V>-xml, php<V>-intl, php<V>-gd`
  - `php<V>-bcmath, php<V>-gmp, php<V>-sqlite3, php<V>-mysql, php<V>-pgsql, php<V>-soap`
  - `php<V>-redis, php<V>-memcached`
  - `php<V>-imagick` (یا **PECL imagick** اگر نصب apt ممکن نبود)
- فایل تنظیمات: `/etc/php/<V>/fpm/conf.d/99-laravel.ini` (کپی برای CLI)
  - `memory_limit=1024M`، `opcache.memory_consumption=256`، `opcache.max_accelerated_files=100000`، فعال‌بودن JIT و ...

## چه چیزهایی نصب نمی‌شود؟
- وب‌سرور نصب نمی‌شود. برای سایت‌ها، سوکت‌های FPM را در وب‌سرور خود تنظیم کنید:
  - `/run/php/php8.2-fpm.sock`، `/run/php/php8.3-fpm.sock`، `/run/php/php8.4-fpm.sock`

## عیب‌یابی
- **Repo “not signed” / NO_PUBKEY**: کلیدهای PPA در `/etc/apt/keyrings/ondrej-php.gpg` ذخیره می‌شوند.
- **PPA 404 برای plucky**: ورودی‌های plucky غیرفعال و سورس **noble** فقط برای `php*` ساخته می‌شود.
- **وابستگی‌های `php8.2-imagick` موجود نیست**: اسکریپت به‌صورت خودکار از PECL نصب و فعال می‌کند.
- **`php -v` همچنان قدیمی است**: احتمال سایه‌زدن مسیرها:
  ```bash
  type -a php
  which php
  readlink -f /usr/bin/php
  ```
  در صورت وجود، `/usr/local/bin/php` یا `/snap/bin/php` را موقتاً تغییرنام دهید.

## حذف
```bash
sudo apt remove --purge 'php8.2*' 'php8.3*' 'php8.4*'
sudo rm -f /etc/apt/sources.list.d/ondrej-php-noble.sources
sudo rm -f /etc/apt/preferences.d/ondrej-php
sudo apt autoremove -y
```

## پیش‌نیازها
Ubuntu 25.x (plucky)، دسترسی sudo، اینترنت.

## مجوز
MIT — فایل `LICENSE`.
