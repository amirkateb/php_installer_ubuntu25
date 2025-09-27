# مُثبّت PHP لأنظمة Ubuntu 25 (plucky)

أداة تثبيت بعملية واحدة لإصدارات **PHP 8.2 / 8.3 / 8.4** على **Ubuntu 25.x**.  
لا يتم تثبيت خادم ويب (لا Nginx ولا Apache). يتم تثبيت PHP (CLI و FPM) مع مجموعة موسعة من الملحقات وضبطٍ مناسب لتطبيقات Laravel والأعباء الثقيلة.

## لماذا هذه الأداة؟
يوفر Ubuntu 25 إصدار PHP 8.4 بشكل رسمي. أما PHP 8.2/8.3 فيأتي عادةً من مستودع PPA (ondrej/php) الذي يدعم إصدارات LTS فقط. تقوم هذه الأداة **بتثبيت مصدر الـ PPA على `noble` بشكل آمن** وتضيف **مفاتيح GPG** الصحيحة بحيث يتم سحب حزم `php*` فقط بينما يبقى النظام على plucky.  
كما تقوم تلقائياً ببناء إضافة `imagick` عبر **PECL** إذا لم تتوفر حزم التوزيعة المتوافقة.

## المزايا
- تثبيت **PHP 8.2 / 8.3 / 8.4** جنباً إلى جنب (الافتراضي: 8.4)
- تثبيت CLI و FPM وملفات التطوير مع مجموعة كبيرة من الملحقات: `curl, zip, mbstring, xml, intl, gd, bcmath, gmp, sqlite3, mysql, pgsql, soap, redis, memcached, opcache`
- إدارة **مفاتيح GPG** و **تثبيت APT مع Pinning** (المصدر على noble ومحجوز بـ `php*`)
- تحسينات أداء جاهزة (Opcache, JIT, memory_limit, realpath cache)
- بناء تلقائي لـ `imagick` عبر PECL عند تعذر تثبيته من الحزم
- تسجيل **update-alternatives** لـ `php`, `phpize`, `php-config`

## البدء السريع
```bash
git clone https://github.com/amirkateb/php_installer_ubuntu25.git
cd php_installer_ubuntu25
chmod +x install-php.sh
sudo ./install-php.sh 8.2   # أو 8.3 / 8.4
```

تشغيل بسطر واحد:
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/amirkateb/php_installer_ubuntu25/main/install-php.sh) 8.2
```

## طريقة الاستخدام
```bash
sudo ./install-php.sh <version>
# <version> = 8.2 | 8.3 | 8.4   (الافتراضي: 8.4)
```

أمثلة:
```bash
sudo ./install-php.sh 8.2
php -v
systemctl status php8.2-fpm --no-pager
```

تبديل الإصدار الافتراضي لـ CLI لاحقاً:
```bash
sudo update-alternatives --config php
sudo update-alternatives --config phpize
sudo update-alternatives --config php-config
```

## ماذا يتم تثبيته؟
- الحزم:
  - `php<V>, php<V>-cli, php<V>-fpm, php<V>-dev, php<V>-common, php<V>-opcache, php<V>-readline`
  - `php<V>-curl, php<V>-zip, php<V>-mbstring, php<V>-xml, php<V>-intl, php<V>-gd`
  - `php<V>-bcmath, php<V>-gmp, php<V>-sqlite3, php<V>-mysql, php<V>-pgsql, php<V>-soap`
  - `php<V>-redis, php<V>-memcached`
  - `php<V>-imagick` (أو بديله عبر **PECL**)
- ملف الضبط: `/etc/php/<V>/fpm/conf.d/99-laravel.ini` (ويُنسخ إلى CLI)
  - مثل: `memory_limit=1024M` و `opcache.memory_consumption=256` و `opcache.max_accelerated_files=100000` مع تفعيل JIT.

## غير مُتضمّن
- لا يوجد خادم ويب. استخدم مقابس FPM في خادمك:
  - `/run/php/php8.2-fpm.sock`, `/run/php/php8.3-fpm.sock`, `/run/php/php8.4-fpm.sock`

## استكشاف الأخطاء
- **Repo “not signed” / NO_PUBKEY**: تضيف الأداة مفاتيح PPA إلى `/etc/apt/keyrings/ondrej-php.gpg`.
- **خطأ 404 مع plucky**: يتم تعطيل إدخالات plucky وإنشاء مصدر **noble** محصور بـ `php*`.
- **مشاكل تبعيات `php8.2-imagick`**: يتم بناء الإضافة عبر PECL وتفعيلها تلقائياً.
- **`php -v` يعرض إصداراً قديماً**: تحقق من مسارات التنفيذ:
  ```bash
  type -a php
  which php
  readlink -f /usr/bin/php
  ```
  أزل أو أعد تسمية `/usr/local/bin/php` أو `/snap/bin/php` إذا كانت تُظلّل `/usr/bin/php`.

## إزالة التثبيت
```bash
sudo apt remove --purge 'php8.2*' 'php8.3*' 'php8.4*'
sudo rm -f /etc/apt/sources.list.d/ondrej-php-noble.sources
sudo rm -f /etc/apt/preferences.d/ondrej-php
sudo apt autoremove -y
```

## المتطلبات
Ubuntu 25.x (plucky)، صلاحيات sudo، اتصال إنترنت.

## الترخيص
MIT — انظر ملف `LICENSE`.
