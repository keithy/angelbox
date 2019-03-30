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

# Arguments to be supplied by build invocation (Docker Compose)
echo "FROM: $FROM"
echo "PHP_VERSION: $PHP_VERSION"
export PHP_VERS=${PHP_VERSION%.*}
echo "PHP_VERS: $PHP_VERS"
echo "MATURITY: $MATURITY"
echo "USER: $USER ($UID)"
echo "BUILDFILE: $BUILDFILE"
 
# abbreviations
alias ext-download="docker-php-ext-download" # extra utility
alias ext-install="docker-php-ext-install -j$(nproc)"
alias ext-enable="docker-php-ext-enable"
alias ext-configure="docker-php-ext-configure"
alias ext-dci="docker-php-ext-download-configure-install" # extra utility

# CONSTANTS & SOURCES
cat "/build/alpine-src/urls.sh"
source "/build/alpine-src/urls.sh"
# Values and extensions selection
source "$BUILD_ENV"

# Bash-strict-mode
# also -x works well in this context
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
IFS=$'\n\t'
set -xeuo pipefail

# GET BUILD-TOOLS AND DEPENDENCIES

if [ ! -f /etc/.build_dependencies ]; then
	# PREPARE BASE FOR COMPILATION

	# Create Non-Root User
	# http://blog.dscpl.com.au/2015/12/random-user-ids-when-running-docker.html
	adduser -D -H -u $UID -G root -g "$USER" $USER || echo "User exists"

	# Setup apk
	apk update
	apk upgrade

	# temporarily install packages necessary for compilation
	apk add --virtual build-dependencies \
	alpine-sdk linux-headers autoconf automake make gdb \
	libtool libzip-dev pcre-dev libxml2-dev \
	re2c strace tzdata zip pwgen \
	htop git nano #user tools

	docker-php-source extract
	pecl channel-update pecl.php.net

	touch /etc/.build_dependencies
fi

# THE BUILD 
 
$ADD_OPCACHE && ext-install opcache
$ADD_OPCACHE && cp /build/conf.d/opcache/opcache-$PHP_CONF.ini /usr/local/etc/php/conf.d

$ADD_SWOOLE || $ADD_SOCKETS && ext-install sockets
# Async server
#swoole
if $ADD_SWOOLE ; then
	apk add libaio-dev libstdc++

  	case $PHP_VERSION in
		*RC*)
			ext-dci swoole $URL_SWOOLE_LATEST
		;;	
		5.5.*|5.6.*)
			ext-dci swoole $URL_SWOOLE_4PHP5_STABLE
		;;
		*)
			#pecl install swoole
			ext-dci swoole $URL_SWOOLE_LATEST
#			ext-dci swoole $URL_SWOOLE_STABLE
# 			ext-dci swoole $URL_SWOOLE_v2_2_0 \
# 				--enable-sockets=no \
# 				--enable-openssl=no \
# 				--enable-http2=no \
# 				--enable-mysqlnd=no \
# 				--enable-coroutine-postgresql=no \
# 				--enable-debug-log=no
		;;
	esac
	apk del libaio-dev
fi

#CRYPTO OPTIONS

#MCRYPT
if $ADD_MCRYPT; then
   	# also libltdl needed (comes with libtool)
   	# http://php.net/manual/en/ref.mcrypt.php#38860
   	apk add libmcrypt-dev 
   	case $PHP_VERSION in
		*RC*)
			ext-dci mcrypt $URL_MCRYPT_LATEST
		;;
		7.1.*)
			ext-dci mcrypt $URL_MCRYPT_v1_0_0
		;;
		7.*) # >7.2
			ext-dci mcrypt $URL_MCRYPT_STABLE
        ;;        
   esac
fi

#SSH2
if $ADD_SSH2; then
    apk add libssh2-dev
	case $PHP_VERSION in
		*RC*)
			ext-dci ssh2 $URL_SSH2_LATEST
		;;
		5.*)
			ext-dci ssh2 $URL_SSH2_4PHP5_STABLE
		;;
		*)
			ext-dci ssh2 $URL_SSH2_STABLE
        ;;
   esac
fi

if $ADD_SODIUM; then
   	case $PHP_VERSION in
# Assume that RCs supply the most recent sodium
#		*RC*)
#			ext-dci sodium $URL_SODIUM_LATEST
#		;;
		5.*)
		   	apk add libsodium-dev
			ext-dci sodium $URL_SODIUM_4PHP5_STABLE
		;;
		7.0|7.1)
		   	apk add libsodium-dev
			ext-dci sodium $URL_SODIUM_STABLE
        ;;     
   esac
fi

#SOAP
$ADD_SOAP && apk add libxml2-dev
$ADD_SOAP && ext-install soap

#BCMATH
$ADD_BCMATH && ext-install bcmath

#ZIP
$ADD_ZIP && ext-install zip

#EXIF
$ADD_EXIF && ext-install exif

#GD
$ADD_GD && apk add freetype-dev libjpeg-turbo-dev libpng-dev
$ADD_GD && ext-configure gd \
    			--with-freetype-dir=/usr/include/ \
				--with-jpeg-dir=/usr/include/ \
				--with-png-dir=/usr/include/ 	
$ADD_GD && ext-install gd

#Intl
$ADD_INTL && apk add icu-dev
$ADD_INTL && ext-install intl 

#PCNTL 
$ADD_PCNTL && ext-install pcntl

#GMP 
$ADD_GMP && apk add gmp-dev
$ADD_GMP && ext-install gmp

#Yaml
if $ADD_YAML; then
	apk add yaml-dev
  	case $PHP_VERSION in
		*RC*)
			ext-dci yaml $URL_YAML_LATEST
		;;
		5.*)
			ext-dci yaml $URL_YAML_4PHP5_STABLE
			#ext-dci yaml $URL_YAML_4PHP5_LATEST
		;;
		*)
			ext-dci yaml $URL_YAML_STABLE
		;;
	esac
fi

#MYSQL || MariaDB
$ADD_MYSQL_LEGACY && ext-download mysql $URL_MYSQL_LEGACY --install
$ADD_MYSQLI && ext-install mysqli
$ADD_PDO_MYSQL && ext-install pdo_mysql 
$ADD_MYSQL_CLIENT && apk add mysql-client
$ADD_MARIADB_CLIENT && apk add mariadb-client

#Postgres
$ADD_PGSQL || $ADD_PDO_PGSQL && apk add postgresql-dev
$ADD_PGSQL && ext-install pgsql
$ADD_PDO_PGSQL && ext-install pdo_pgsql
$ADD_PG_CLIENT && apk add postgresql-client

#SQLite
if $ADD_SQLITE_LIBS; then
   case $PHP_VERS in
		5.*|7.0|7.1|7.2|7.3 ) # built in
		;;
		*) # >=7.4 http://php.net/manual/en/sqlite3.requirements.php
			apk add sqlite-libs
        ;;        
   esac
fi
 
#Mongo
if $ADD_MONGO; then
  	case $PHP_VERSION in
		*RC*)
			# ext-dci mongodb $URL_MONGO_LATEST
			pecl mongodb install #succeeds where ext-dci fails
		;;
		5.3.*|5.4.*)
			ext-dci mongo $URL_MONGO_4PHP5_STABLE
		;;
		5.5.*|5.6.*)
			#ext-dci mongodb $URL_MONGO_STABLE
			pecl mongodb install #succeeds where ext-dci fails
		;;
		*)
			#ext-dci mongodb $URL_MONGO_LATEST
			pecl mongodb install #succeeds where ext-dci fails
		;;
	esac
fi

# SESSION/SHARED MEMORY SOLUTIONS

#igbinary
if $ADD_IGBINARY; then
  	case $PHP_VERSION in
		*RC*)
			ext-dci igbinary $URL_IGBINARY_LATEST
		;;
		*)
			ext-dci igbinary $URL_IGBINARY_STABLE
		;;
	esac
fi
 
#msgpack
if $ADD_MSGPACK; then
  	case $PHP_VERSION in
		*RC*)
			ext-dci msgpack $URL_MSGPACK_LATEST
		;;
		5.*)
			ext-dci msgpack $URL_MSGPACK_4PHP5_LATEST
			#ext-download msgpack $URL_MSGPACK_4PHP5_STABLE
		;;
		*)
			ext-dci msgpack $URL_MSGPACK_STABLE
		;;
	esac
	#msgpack must be loaded before memcached
	INI=/usr/local/etc/php/conf.d/docker-php-ext-msgpack.ini
	[ -f $INI ] mv $INI 00_$INI
fi

#memcached
if $ADD_MEMCACHED; then

	PARAMS="--enable-memcached-json"
	[ -f /usr/local/etc/php/conf.d/docker-php-ext-igbinary.ini ] && PARAMS="$PARAMS --enable-memcached-igbinary"
	[ -f /usr/local/etc/php/conf.d/docker-php-ext-msgpack.ini ] && PARAMS="$PARAMS --enable-memcached-msgpack"
	
	apk add libmemcached-dev cyrus-sasl-dev
	
  	case $PHP_VERSION in
		*RC*)
			ext-dci memcached $URL_MEMCACHED_LATEST $PARAMS
		;;
		5.*)
			ext-dci memcached $URL_MEMCACHED_4PHP5_STABLE
		;;
		*)
			ext-dci memcached $URL_MEMCACHED_STABLE $PARAMS
		;;
	esac
	
	#memcached must be loaded after msgpack and igbinary
	INI=/usr/local/etc/php/conf.d/docker-php-ext-memcached.ini
	[ -f $INI ] mv $INI zz_$INI

# configure options	
#	ext-configure memcached \
#		--disable-memcached-session \
#		--enable-memcached-igbinary \
#		--enable-memcached-json \
#		--enable-memcached-msgpack \
#		--disable-memcached-sasl \
#		--enable-memcached-protocol \
# 		--with-system-fastlz 
 
fi

#redis
if $ADD_REDIS ; then
  	case $PHP_VERSION in
		*RC*)
			ext-dci redis $URL_REDIS_LATEST
		;;	
		*)
			ext-dci redis $URL_REDIS_STABLE
		;;
	esac
fi

#hiredis
if $ADD_HIREDIS ; then
  	case $PHP_VERSION in
		*RC*)
			ext-download hiredis $URL_HIREDIS_LATEST
		;;	
		*)
			ext-download hiredis $URL_HIREDIS_STABLE
		;;
	esac
	cd /usr/src/php/ext/hiredis
	make
	make install
fi

#hiredis
if $ADD_NGHTTP2 ; then
  	case $PHP_VERSION in
		*RC*)
			ext-download hiredis $URL_NGHTTP2_LATEST
		;;	
		*)
			ext-download hiredis $URL_NGHTTP2_STABLE
		;;
	esac
	cd /usr/src/php/ext/nghttp2
	autoreconf -i 
	automake
	autoconf
	./configure
	make
	make install
fi

#AMQP
if $ADD_AMQP ; then
	apk add rabbitmq-c-dev
  	case $PHP_VERSION in
		*RC*)
			ext-dci amqp $URL_AMQP_LATEST
		;;	
		*)
			ext-dci redis $URL_AMQP_STABLE
		;;
	esac
fi

# LDAP NOT WORKING
# if $ADD_LDAP ; then
# 	apk add libldap-dev
#   	case $PHP_VERSION in
# 		*RC*)
# 			ext-dci ldap $URL_LDAP_LATEST
# 		;;	
# 		*)
# 			ext-install ldap
# 		;;
# 	esac
# fi

#ARG INSTALL_BLACKFIRE=false
# PHP Aerospike:
# IonCube
# GHOSTSCRIPT:
# SQL SERVER:
# Image optimizers:
# ImageMagick:
# IMAP:
# Calendar:
# Phalcon:
#libressl alternative to openssl openssh

# IMAGE_OPTIMIZERS
$ADD_IMAGE_OPTIMIZERS && apk add jpegoptim optipng pngquant gifsicle

#Imagick
if $ADD_IMAGICK ; then
	apk add imagemagick-dev
  	case $PHP_VERSION in
		*RC*)
			ext-dci imagick $URL_IMAGICK_LATEST
		;;	
		*)
			ext-dci imagick $URL_IMAGICK_STABLE
		;;
	esac
fi

#xdebug
if $ADD_XDEBUG; then
  	case $PHP_VERSION in
		*RC*)
			ext-dci xdebug $URL_XDEBUG_LATEST
		;;
		5.*)
			ext-dci xdebug $URL_XDEBUG_4PHP5
		;;		
		*)
			ext-dci xdebug $URL_XDEBUG_STABLE
		;;
	esac
	cp /build/conf.d/xdebug/* /usr/local/etc/php/conf.d
	if [ -f /usr/local/etc/php/conf.d/docker-php-ext-swoole.ini ]; then
	 	mv docker-php-ext-xdebug.ini docker-php-ext-xdebug.iniX
	fi
fi

#composer
$ADD_COMPOSER && curl -sS $URL_COMPOSER_INSTALLER \
	| php -- --install-dir=/usr/bin --filename=composer 

#wp-cli
$ADD_WPCLI && curl -o /usr/local/bin/wp $URL_WPCLI 
[ -f /usr/local/bin/wp ] && chmod +x /usr/local/bin/wp

#/usr/local/etc/php/conf.d
cp -R /build/conf.d/$PHP_CONF/* /usr/local/etc/php/conf.d

#Timezone
echo "${TIMEZONE:-UTC}" > /etc/timezone 

#Port
sed -i 's/127.0.0.1:9000/0.0.0.0:$FPM_PORT/g' /usr/local/etc/php-fpm.d/www.conf

#ensure ownership
chmod -R ug+w /var/www/html
chown -R $UID:root /var/www/html

