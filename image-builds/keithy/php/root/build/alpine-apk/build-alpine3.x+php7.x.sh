#!/bin/sh

ALPINE_VERS="$1"
PHP_VERS="$2"

DIR=${BUILD_SCRIPT%/*}

echo "FROM: $FROM"
echo "USER: $USER ($UID)"
echo "DIR: $DIR"
echo "BUILD_ENV: $BUILD_ENV"
echo "BUILD_SCRIPT: $BUILD_SCRIPT"
echo "BUILD_CONFIG: $BUILD_CONFIG"
echo "ALPINE_VERS: [$ALPINE_VERS]"
echo "PHP_VERS: [$PHP_VERS]"

# FUNCTIONS
source /build/functions.sh

# CONSTANTS & SOURCES
cat "$DIR/urls.sh"
source "$DIR/urls.sh"

# Values and extensions selection
source "$BUILD_ENV"
#tweaks applying rules
ADD_SWOOLE_PECL=${ADD_SWOOLE_PECL:-false}
$ADD_SWOOLE || $ADD_SWOOLE_PECL && ADD_SOCKETS=true
$ADD_SWOOLE_PECL && ADD_SWOOLE=false

IFS=$'\n\t'
set -xeuo pipefail

# Setup apk
apk update
apk upgrade

apk add --update curl ca-certificates

# Access codecasts alternative repository on github
# download the repository public key
curl https://dl.bintray.com/php-alpine/key/php-alpine.rsa.pub -o /etc/apk/keys/php-alpine.rsa.pub
# add the repository for the php / alpine version corresponding

echo "@php https://dl.bintray.com/php-alpine/v${ALPINE_VERS}/php-${PHP_VERS}" >> /etc/apk/repositories
apk update
apk upgrade

#echo "UserKnownHostsFile /.ssh-agent/known_hosts" >> /etc/ssh/ssh_config

deps=""
add="$add openssh-client openssl php7-common@php php@php"

$ADD_APACHE2 && add="$add php-apache2@php"
$ADD_AMQP && add="$add php-amqp@php"
$ADD_APCU && add="$add php-apcu@php" 
$ADD_ARGON2 && add="$add php-argon2@php libargon2@php" 
$ADD_BCMATH && add="$add php-bcmath@php"
$ADD_BZ2 && add="$add php-bz2@php"
$ADD_CALENDAR && add="$add php-calendar@php"
$ADD_CGI && add="$add php-cgi@php"
$ADD_COMPOSER && add="$add php-phar@php php-iconv@php php-mbstring@php php-json@php php-openssl@php" 
$ADD_CTYPE && add="$add php-ctype@php"
$ADD_CURL && add="$add php-curl@php"
$ADD_DBA && add="$add php-dba@php"
$ADD_DOC && add="$add php-doc@php"
$ADD_DOM && add="$add php-dom@php"
$ADD_DS && add="$add php-ds@php"
$ADD_EMBED && add="$add php-embed@php"
$ADD_ENCHANT && add="$add php-enchant@php"
$ADD_EXIF && add="$add php-exif@php"
$ADD_FPM && add="$add php-fpm@php"
$ADD_FTP && add="$add php-ftp@php"
$ADD_GD && add="$add php-gd@php"
$ADD_GETTEXT && add="$add php-gettext@php"
$ADD_GMP && add="$add php-gmp@php"
$ADD_GMAGICK && add="$add graphicsmagick" && deps="$deps graphicsmagick-dev"
$ADD_ICONV && add="$add php-iconv@php"
$ADD_IMAGE_OPTIMIZERS && add="$add jpegoptim optipng pngquant gifsicle"
$ADD_IMAGICK && add="$add php-imagick@php"
$ADD_IMAP && add="$add php-imap@php"
$ADD_INTL && add="$add php-intl@php"
$ADD_IONCUBE && echo "ioncube - not yet" ######
$ADD_JSON && add="$add php-json@php"
$ADD_LDAP && add="$add php-ldap@php"
$ADD_LITESPEED && add="$add php-litespeed@php"
#$ADD_MCRYPT && add="$add php-mcrypt@php" # Not in 7.3 repo
$ADD_MBSTRING && add="$add php-mbstring@php"
# https://github.com/php-memcached-dev/php-memcached/issues/378
$ADD_MEMCACHED && add="$add php-memcached@php"
  $ADD_IGBINARY && echo "IGBINARY comming soon"
  $ADD_MSGPACK && add="$add php-msgpack@php"
$ADD_MONGO && add="$add php-mongodb@php"
$ADD_MYSQLI && add="$add php-mysqli@php php-mysqlnd@php php-openssl@php"
$ADD_MYSQL_CLIENT && add="$add mysql-client"  
  $ADD_MARIADB_CLIENT && add="$add mariadb-client"  
$ADD_MYSQL_LEGACY && echo "mysql legacy - not supported" ######
  $ADD_MYSQL_COMPAT && echo "mysql compatability - not yet supported" ######
$ADD_ODBC && add="$add php-odbc@php"
$ADD_OPCACHE && add="$add php-opcache@php"
$ADD_OPENSSL && add="$add php-openssl@php"
$ADD_PCNTL && add="$add php-pcntl@php"
$ADD_PDO_MYSQL && add="$add php-pdo@php php-pdo_mysql@php php-mysqlnd@php"
$ADD_PDO_PGSQL && add="$add php-pdo@php php-pdo_pgsql@php" 
$ADD_PDO_SQLITE && add="$add php-pdo@php php-pdo_sqlite@php" 
$ADD_PEAR && add="$add php-pear@php"
$ADD_PGSQL && add="$add php-pgsql@php"
$ADD_PG_CLIENT && add="$add postgresql-client"
$ADD_PHALCON && add="$add php-phalcon@php php-openssl@php"
$ADD_PHAR && add="$add php-phar@php"
$ADD_PHPDBG && add="$add php-phpdbg@php"
$ADD_POSIX && add="$add php-posix@php"
$ADD_PSR && add="$add php-psr@php"
$ADD_REDIS && add="$add php-redis@php" # $ADD_HIREDIS=false
$ADD_SCALAR_OBJECTS && add="$add php-scalar_objects@php"
$ADD_SESSION && add="$add php-session@php"
$ADD_SOAP && add="$add php-soap@php"
$ADD_SOCKETS && add="$add php-sockets@php"
$ADD_SODIUM && add="$add php-sodium@php php-libsodium@php"
$ADD_SQLITE3 && add="$add php-sqlite3@php"
#$ADD_SQLITE_LIBS && add="$add sqlite-libs" #uncomment for PHP7.4+
#$ADD_SSH2 && add="$add php-ssh2@php" # Not in 7.3 repo
$ADD_SWOOLE && add="$add php-swoole@php" 
$ADD_WPCLI && true
$ADD_XDEBUG && add="$add php-xdebug@php" # either or
$ADD_XML && add="$add php-xml@php" 
$ADD_XMLREADER && add="$add php-xmlrpc@php" 
$ADD_XMLRPC && add="$add php-xmlrpc@php" 
$ADD_YAML && add="$add yaml" && deps="$deps yaml-dev"
$ADD_ZIP && add="$add php-zip@php" 
$ADD_ZLIB && add="$add php-zlib@php" 

#extras (saying yes to all options)
$ADD_SWOOLE_PECL && add="$add libstdc++" && deps="$deps libaio-dev pcre2-dev openssl-dev" 

echo "Installing: $add"
IFS=$' '
apk add --update --clean-protected $add

# Codecasts installs binaries with php7 link them to php.
for binary in /usr/bin/*7 /usr/lib/php7 /usr/include/*7 /usr/sbin/*7 /usr/share/php7; do
  [[ -e $binary ]] && ln -s $binary ${binary::-1}
done 

# https://github.com/codecasts/php-alpine/issues/68
[[ -f /etc/php7/conf.d/00_ds.ini ]] && mv /etc/php7/conf.d/00_ds.ini /etc/php7/conf.d/01_ds.ini

# To enable installation from pecl
# temporarily install packages necessary for compilation
if [ -n "$deps" ]; then
  apk add php7-pear@php php-dev@php
  deps="$deps alpine-sdk linux-headers autoconf automake make gdb"
  deps="$deps libzip-dev pcre-dev libxml2-dev re2c strace tzdata zip pwgen libtool"
  apk add --virtual .build-dependencies $deps
  
  pecl config-set php_ini /etc/php7/php.ini
  pecl config-set ext_dir /usr/lib/php7/modules
  pecl channel-update pecl.php.net
  pear channel-update pear.php.net
	
fi

if $ADD_SWOOLE_PECL; then
#  pecl install "$PECL_SWOOLE"
  yes | pecl install swoole || true
  echo "extension=swoole" > /etc/php7/conf.d/00_swoole_pecl.ini
fi

if $ADD_GMAGICK; then
  pecl install "$PECL_GMAGICK"
  echo "extension=gmagick" > /etc/php7/conf.d/20_gmagick.ini
fi

if $ADD_YAML; then
  sudo pecl install "$PECL_YAML"
  echo "extension=yaml" > /etc/php7/conf.d/01_yaml.ini
fi

if $ADD_IGBINARY; then
  pecl install "$PECL_IGBINARY"  
  echo "extension=igbinary" > /etc/php7/conf.d/20_igbinary.ini
fi

if $ADD_COMPOSER; then
  curl -sS $URL_COMPOSER_INSTALLER | php -- --install-dir=/usr/bin --filename=composer
fi
$ADD_WPCLI && curl -o /usr/local/bin/wp $URL_WPCLI && chmod +x /usr/local/bin/wp
 
# php7-simplexml \

# don't run as root
# http://blog.dscpl.com.au/2015/12/random-user-ids-when-running-docker.html
adduser -D -H -u $UID -G root -g "$USER" $USER

#ensure wp ownership
if [[ -d /var/www ]]; then
  chmod -R ug+w /var/www
  chown -R $USER:root /var/www
fi

# Post Install Config Options
[ -f $BUILD_CONFIG ] && source "$BUILD_CONFIG"

#Timezone
echo "${TIMEZONE:-UTC}" > /etc/timezone 

cp "$DIR/clean-apk.sh" "/build/CLEAN.sh"


