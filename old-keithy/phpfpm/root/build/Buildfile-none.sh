USER=docker
export UID=$UID

TIMEZONE="Europe/London"
FPM_PORT=9000

ADD_OPCACHE=false
ADD_SOCKETS=false
ADD_SWOOLE=false

# CRYPTO options
ADD_MCRYPT=false
ADD_SSH2=false
ADD_SODIUM=false

ADD_BCMATH=false
ADD_ZIP=false
ADD_EXIF=false
ADD_SOAP=false
ADD_GD=false
ADD_INTL=false
ADD_PCNTL=false
ADD_GMP=false

ADD_YAML=false

# DB Options
ADD_MYSQL_LEGACY=false
ADD_MYSQL_COMPAT=false #(not yet)
ADD_MYSQLI=false
ADD_PDO_MYSQL=false
ADD_MYSQL_CLIENT=false
ADD_MARIADB_CLIENT=false
ADD_PGSQL=false
ADD_PDO_PGSQL=false
ADD_PG_CLIENT=false
ADD_SQLITE_LIBS=false #for 7.4+
ADD_MONGO=false

#doesn't build php7.3
#https://github.com/php-memcached-dev/php-memcached/issues/378
#memcached Options
ADD_IGBINARY=false
ADD_MSGPACK=false
ADD_MEMCACHED=false

ADD_REDIS=false
ADD_HIREDIS=false

# OTHER SERVICES
ADD_AMQP=false
ADD_LDAP=false
ADD_IONCUBE=false

ADD_IMAGE_OPTIMIZERS=false
ADD_IMAGICK=false

ADD_COMPOSER=false
ADD_WPCLI=false

ADD_XDEBUG=false

PHP_CONF="development"
#PHP_CONF="production"

source /build/build-alpine.sh

#source /build/clean-alpine.sh