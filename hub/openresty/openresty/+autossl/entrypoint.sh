#!/bin/bash

# KPHMOD added this here.
# In AngelBox we aim to make all specialised images as similar to the official docker hub 
# images as possible. Rather than replace the standard entrypoint, we provide this one
# as an alternative, allowing the original entrypoint.sh to still be used. 
# Thus autossl can be enabled and disabled by including/omitting 
# /hub/openresty/openresty/+autossl.yml

set -x

source /etc/profile

ANGEL_DIR="/etc/autossl"
RESTY_DIR="/usr/local/openresty/nginx/conf"
NGINX_DIR="/etc/nginx"
TEMPLATES_DIR="${ANGEL_DIR}/templates"

# openresty will change it later on its own, right now we're just giving it access
chmod 777 /etc/resty-auto-ssl

# we want to keep dhparam.pem in volume, to generate just one time
if [ ! -f "/etc/resty-auto-ssl/dhparam.pem" ]; then
  if [ -n "$DIFFIE_HELLMAN" ]; then
    openssl dhparam -out /etc/resty-auto-ssl/dhparam.pem 2048
  else
    cp ${RESTY_DIR}/dhparam.pem /etc/resty-auto-ssl/dhparam.pem
  fi
fi

########

# if $SITES is defined, we should prepare configuration files
# the format is template_name:domain_name=proxy_server_endpoint
#
# example usage:
# -e SITES="php_fpm:db.example.com=localhost:5432;php_apache:app.example.com=http://localhost:8080"
#
# it will create 2 files:
#
# 1. /etc/nginx/conf.d/db.example.com-site.conf using $SERVER_ENDPOINT=localhost:5432 and $SERVER_NAME=db.example.com
# 2. /etc/nginx/conf.d/app.example.com-site.conf using $SERVER_ENDPOINT=localhost:8080 and $SERVER_NAME=app.example.com

if [ -n "$SITES" ]; then
  # lets read all backends, separated by ';'
  IFS=\; read -a SITES_LIST <<<"$SITES"

  # for each backend (in form of server_name=endpoint:port) we create proper file
  for EACH in "${SITES_LIST[@]}"; do
    AFTER_EQUALS=${EACH#*=}
    SERVER_ENDPOINT=${AFTER_EQUALS#*//}  # it clears url scheme, like http:// or https://
	BEFORE_EQUALS=${EACH%=*}
	TEMPLATE=${BEFORE_EQUALS%:*} # Before colon
    SERVER_NAME=${BEFORE_EQUALS#*:} # After colon
    
    sed \
    -e "s/\$SERVER_NAME/$SERVER_NAME/g" \
    -e "s/\$SERVER_ENDPOINT/$SERVER_ENDPOINT/g" \
    ${TEMPLATES_DIR}/${TEMPLATE}.tmpl > ${NGINX_DIR}/${SERVER_NAME}-site.conf
  
  done
fi

# substitute $ALLOWED_DOMAINS, $LETSENCRYPT_URL into OpenResty autossl-http.conf 
if [ -n "$ALLOWED_DOMAINS" ]; then

  sed \
  -e "s/\$ALLOWED_DOMAINS/$ALLOWED_DOMAINS/g" \
  -e "s|\$LETSENCRYPT_URL|$LETSENCRYPT_URL|g" \
  ${ANGEL_DIR}/autossl.conf > ${NGINX_DIR}/autossl.conf 

else
  echo "Angelbox requires \$WORKER_PROCESSES be defined"
  exit
fi


# substitute $WORKER_PROCESSES into OpenResty configuration
# Applying the substitution in this way means that the default file is valid as it is.

if [ -n "$WORKER_PROCESSES" ]; then

  sed \
  -e "s/worker_processes .;/worker_processes $WORKER_PROCESSES;/" \
  ${ANGEL_DIR}/nginx.conf > ${RESTY_DIR}/nginx.conf 

else
  echo "Angelbox requires \$WORKER_PROCESSES be defined"
  exit
fi

if [ -n "$@" ]; then
  exec "$@"
fi

/usr/local/openresty/bin/openresty -g "daemon off;"

