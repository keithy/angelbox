#!/bin/sh

# FUNCTIONS
source /build/functions.sh

# CONSTANTS & SOURCES
source /build/urls.sh && cat /build/urls.sh

# allowed domains should be lua match pattern

ENV DIFFIE_HELLMAN "\${DIFFIE_HELLMAN:-}"
ENV ALLOWED_DOMAINS "\${ALLOWED_DOMAINS:-.*}"
ENV AUTO_SSL_VERSION "\${AUTO_SSL_VERSION:-0.11.1}"
ENV FORCE_HTTPS "\${FORCE_HTTPS:-true}"
ENV SITES "\${SITES:-}"
ENV LETSENCRYPT_URL "\${LETSENCRYPT_URL:-https://acme-v01.api.letsencrypt.org/directory}"

# Here we install open resty and generate dhparam.pem file.
# You can specify DIFFIE_HELLMAN=true to force regeneration of that file on first run
# also we create fallback ssl keys

apk add openssl

USER=root /usr/local/openresty/luajit/bin/luarocks install lua-resty-http
USER=root /usr/local/openresty/luajit/bin/luarocks install lua-resty-auto-ssl $AUTO_SSL_VERSION

openssl req -new -newkey rsa:2048 -days 3650 -nodes -x509 \
    -subj '/CN=sni-support-required-for-valid-ssl' \
    -keyout /etc/ssl/resty-auto-ssl-fallback.key \
    -out /etc/ssl/resty-auto-ssl-fallback.crt 
    
openssl dhparam -out /usr/local/openresty/nginx/conf/dhparam.pem 2048 \

mv /build/conf-autossl/nginx.conf /usr/local/openresty/nginx/conf/
mv /build/conf-autossl/snippets/* /usr/local/openresty/nginx/conf/
mv /build/conf-autossl/entrypoint_autossl.sh /entrypoint_autossl.sh

