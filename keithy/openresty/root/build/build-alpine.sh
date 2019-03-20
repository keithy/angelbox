#!/bin/sh

# Bash-strict-mode
# also -x works well in this context
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
IFS=$'\n\t'
set -euo pipefail

# Arguments to be supplied by build invocation (Docker Compose)
echo "PWD: " $(pwd)
echo "FROM: $FROM"
echo "USER: $USER ($UID)"
echo "BUILD_SCRIPT: $BUILD_SCRIPT"
echo "BUILD_CONFIG: $BUILD_CONFIG"

# CONSTANTS & SOURCES
source /build/urls.sh && cat /build/urls.sh

set -x

# Config Options
source /build/${BUILD_CONFIG:-config-default.sh}

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
        ${RESTY_ADD_PACKAGE_BUILDDEPS} \
        gd \
        geoip \
        libgcc \
        libxslt \
        zlib \
        ${RESTY_ADD_PACKAGE_RUNDEPS} \
        htop git nano #user tools

# other possibilities
#     alpine-sdk linux-headers autoconf automake make gdb \
#     libtool libzip-dev pcre-dev libxml2-dev \
#     re2c strace tzdata zip pwgen \

    touch /etc/.build_dependencies
fi

# THE BUILD

cd /tmp

if [ -n "${RESTY_EVAL_PRE_CONFIGURE:-}" ]; then eval $(echo ${RESTY_EVAL_PRE_CONFIGURE}); fi 

# Download Sources

mkdir -p openssl && curl -fSL ${URL_OPENSSL_4_ALPINE} | tar xz --strip-components=1 -C openssl
mkdir -p pcre    && curl -fSL ${URL_PCRE}             | tar xz --strip-components=1 -C pcre
mkdir -p resty   && curl -fSL ${URL_RESTY}            | tar xz --strip-components=1 -C resty

RESTY_J="${RESTY_J:-2}"
cd /tmp/resty
echo "./configure -j${RESTY_J} --with-openssl=/tmp/openssl --with-pcre=/tmp/pcre \\" > configure.sh
echo "${RESTY_CONFIG_OPTIONS} ${RESTY_CONFIG_OPTIONS_MORE}" >> configure.sh

source configure.sh
make -j$RESTY_J
make -j$RESTY_J install

cd /tmp
if [ -n "${RESTY_EVAL_POST_MAKE:-}" ]; then eval $(echo ${RESTY_EVAL_POST_MAKE}); fi

# link stderr/stdout to logs
ln -sf /dev/stdout /usr/local/openresty/nginx/logs/access.log
ln -sf /dev/stderr /usr/local/openresty/nginx/logs/error.log

echo "PATH=$PATH:/usr/local/openresty/luajit/bin" > /etc/profile.d/build-alpine-env.sh
echo "PATH=$PATH:/usr/local/openresty/nginx/sbin" >> /etc/profile.d/build-alpine-env.sh
echo "export PATH=$PATH:/usr/local/openresty/bin" >> /etc/profile.d/build-alpine-env.sh

#Timezone
echo "${TIMEZONE:-UTC}" > /etc/timezone 

#ensure ownership
mkdir -p /var/www/html
chmod -R ug+w,g+s /var/www/html
chown -R $UID:root /var/www/html /entrypoint.sh /etc/nginx
