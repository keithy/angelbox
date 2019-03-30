#!/bin/sh

# Bash-strict-mode
# also -x works well in this context
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
IFS=$'\n\t'
set -euo pipefail

ALPINE_VERS="$1"

DIR=${BUILD_SCRIPT%/*}

echo "FROM: $FROM"
echo "USER: $USER ($UID)"
echo "DIR: $DIR"
echo "BUILD_ENV: $BUILD_ENV"
echo "BUILD_SCRIPT: $BUILD_SCRIPT"
echo "BUILD_CONFIG: $BUILD_CONFIG"
echo "ALPINE_VERS: [$ALPINE_VERS]"

set -x

# FUNCTIONS
source /build/functions.sh

# Values and extensions selection
[ -f "$DIR/$BUILD_ENV" ] && source "$DIR/$BUILD_ENV"

# CONSTANTS & SOURCES
source ${DIR}/urls.sh && cat ${DIR}/urls.sh

# Config Options
source ${BUILD_CONFIG:-config-default.sh}

# GET BUILD-TOOLS AND DEPENDENCIES
# PREPARE BASE FOR COMPILATION

# Create Non-Root User
# http://blog.dscpl.com.au/2015/12/random-user-ids-when-running-docker.html
[[ "$UID" != "0" ]] && adduser -D -H -u $UID -G root -g "$USER" $USER || echo "User exists"

# Setup apk
apk update
apk upgrade

# temporarily install packages necessary for compilation
apk add --virtual .build-dependencies \
	build-base \
	curl \
	gd-dev \
	geoip-dev \
	libxslt-dev \
	linux-headers \
	make \
	perl-dev \
	readline-dev \
	zlib-dev \
	${RESTY_ADD_PACKAGE_BUILDDEPS}

apk add gd \
	geoip \
	libgcc \
	libxslt \
	zlib \
	${RESTY_ADD_PACKAGE_RUNDEPS}
	
# THE BUILD

cd /tmp

[ -n "${RESTY_EVAL_PRE_CONFIGURE:-}" ] && eval $(echo ${RESTY_EVAL_PRE_CONFIGURE})

# Download Sources

mkdir -p openssl && curl -fSL ${URL_OPENSSL_4_ALPINE} | tar xz --strip-components=1 -C openssl
mkdir -p pcre    && curl -fSL ${URL_PCRE}             | tar xz --strip-components=1 -C pcre
mkdir -p resty   && curl -fSL ${URL_RESTY}            | tar xz --strip-components=1 -C resty

cd /tmp/resty
echo "./configure --with-openssl=/tmp/openssl --with-pcre=/tmp/pcre \\" > configure.sh
echo "${RESTY_CONFIG_OPTIONS} ${RESTY_CONFIG_OPTIONS_MORE}" >> configure.sh

source configure.sh
make 
make install

cd /tmp

[ -n "${RESTY_EVAL_POST_MAKE:-}" ] && eval $(echo ${RESTY_EVAL_POST_MAKE})

# link stderr/stdout to logs
ln -sf /dev/stdout /usr/local/openresty/nginx/logs/access.log
ln -sf /dev/stderr /usr/local/openresty/nginx/logs/error.log

PATH=$PATH:/usr/local/openresty/luajit/bin
PATH=$PATH:/usr/local/openresty/nginx/sbin
PATH=$PATH:/usr/local/openresty/bin

ENV PATH

cp /build/conf/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
mkdir -p /etc/nginx/conf.d
cp /build/conf/nginx.vh.default.conf /etc/nginx/conf.d/default.conf
cp /build/html/* /usr/local/openresty/nginx/html

#Timezone
echo "${TIMEZONE:-UTC}" > /etc/timezone 

#ensure ownership
mkdir -p /var/www/html
chmod -R ug+w,g+s /var/www/html
chown -R $UID:root /var/www/html /entrypoint.sh /etc/nginx /usr/local/openresty

#sudo setcap CAP_NET_BIND_SERVICE=+eip /path to nginx?

 
