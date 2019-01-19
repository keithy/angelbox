#!/bin/sh

echo "FROM: $FROM"
echo "USER: $USER ($UID)"
echo "BUILD_ENV: $BUILD_ENV"
echo "BUILD_SCRIPT: $BUILD_SCRIPT"

[ -f  $BUILD_ENV ] && source $BUILD_ENV

# don't run as root
# http://blog.dscpl.com.au/2015/12/random-user-ids-when-running-docker.html
adduser -D -H -u $UID -G root -g "$USER" $USER

# Setup apk

apk update
apk upgrade

apk add curl ca-certificates
apk add openssh-client

echo "UserKnownHostsFile /.ssh-agent/known_hosts" >> /etc/ssh/ssh_config

#apk add alpine-sdk

apk add less postfix mariadb-client

apk add php7 \
		php7-fpm \
		php7-memcached \
		php7-gd \
		php7-mysqli \
		php7-pdo \
        php7-pdo_mysql \
		php7-zip \
        php7-json \
        php7-zlib \
        php7-session \
        php7-xml \
        php7-phar \
        php7-gd \
        php7-iconv \
        php7-curl \
        php7-openssl \
        php7-mcrypt \
        php7-opcache \
        php7-ctype \
        php7-apcu \
        php7-intl \
        php7-bcmath \
        php7-mbstring \
        php7-dom \
        php7-xmlreader \
        php7-simplexml \
		php7-sockets  \
		php7-xdebug

curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer 

#ensure wp ownership
chmod -R ug+w /var/www/html
chown -R $USER:root /var/www/html

# make a fake bash for alpine /bin/bash if missing
if [ ! -f /bin/bash ]; then
  echo "#!/bin/sh" > /usr/bin/bash
  echo "exec sh \"\$@\"" >> /usr/bin/bash 
  chmod a+x /usr/bin/bash
fi

# purge package cache
rm -rf /var/cache/apk/*
# tidy up
rm -rf /build 
