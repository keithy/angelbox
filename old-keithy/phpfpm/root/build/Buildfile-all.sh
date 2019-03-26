USER=docker
export UID=$UID

TIMEZONE="Europe/London"
FPM_PORT=9000

ADD_OPCACHE=true
ADD_SOCKETS=true
ADD_SWOOLE=true # disables xdebug (incompatible)

# CRYPTO options
ADD_MCRYPT=true
ADD_SSH2=true
ADD_SODIUM=true

ADD_BCMATH=true
ADD_ZIP=true
ADD_EXIF=true
ADD_SOAP=true
ADD_GD=true
ADD_INTL=true
ADD_PCNTL=true
ADD_GMP=true

ADD_YAML=true

# DB Options
ADD_MYSQL_LEGACY=true
ADD_MYSQL_COMPAT=true #(not yet)
ADD_MYSQLI=true
ADD_PDO_MYSQL=true
ADD_MYSQL_CLIENT=true
ADD_MARIADB_CLIENT=true
ADD_PGSQL=true
ADD_PDO_PGSQL=true
ADD_PG_CLIENT=true
ADD_SQLITE_LIBS=true #for 7.4+
ADD_MONGO=true

#doesn't build php7.3
#https://github.com/php-memcached-dev/php-memcached/issues/378
#memcached Options
ADD_IGBINARY=true
ADD_MSGPACK=true
ADD_MEMCACHED=true

ADD_REDIS=true
ADD_HIREDIS=true

# OTHER SERVICES
ADD_AMQP=true
ADD_LDAP=true
ADD_IONCUBE=false

ADD_IMAGE_OPTIMIZERS=true
ADD_IMAGICK=true

ADD_COMPOSER=true
ADD_WPCLI=true

ADD_XDEBUG=true

PHP_CONF="development"
#PHP_CONF="production"

source /build/build-alpine.sh

source /build/clean-alpine.sh