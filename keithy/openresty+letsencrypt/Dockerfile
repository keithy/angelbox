ARG FROM=keithy/openresty-no-sse4.2:alpine-fat

FROM ${FROM}

ARG FROM=keithy/openresty-no-sse4.2:alpine-fat

# allowed domains should be lua match pattern
ENV DIFFIE_HELLMAN='' ALLOWED_DOMAINS='.*' AUTO_SSL_VERSION='0.11.1' FORCE_HTTPS='true' SITES='' LETSENCRYPT_URL='https://acme-v01.api.letsencrypt.org/directory'

# Here we install open resty and generate dhparam.pem file.
# You can specify DIFFIE_HELLMAN=true to force regeneration of that file on first run
# also we create fallback ssl keys
RUN apk --no-cache add bash openssl \
    && /usr/local/openresty/luajit/bin/luarocks install lua-resty-auto-ssl $AUTO_SSL_VERSION \
    && openssl req -new -newkey rsa:2048 -days 3650 -nodes -x509 \
    -subj '/CN=sni-support-required-for-valid-ssl' \
    -keyout /etc/ssl/resty-auto-ssl-fallback.key \
    -out /etc/ssl/resty-auto-ssl-fallback.crt \
    && openssl dhparam -out /usr/local/openresty/nginx/conf/dhparam.pem 2048 \
    # let's remove default open resty configuration, we'll conditionally add modified version in entrypoint.sh
    && rm /etc/nginx/conf.d/default.conf

COPY  docker-nginx-auto-ssl/nginx.conf  docker-nginx-auto-ssl/snippets /usr/local/openresty/nginx/conf/
COPY docker-nginx-auto-ssl/entrypoint.sh /entrypoint-orig.sh
COPY entrypoint.sh /entrypoint.sh

VOLUME /etc/resty-auto-ssl

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/local/openresty/bin/openresty", "-g", "daemon off;"]
