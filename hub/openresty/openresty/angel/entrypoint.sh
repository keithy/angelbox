#!/bin/sh

source /etc/profile

ANGEL_DIR="/etc/angel"
RESTY_DIR="/usr/local/openresty/nginx/conf"
NGINX_DIR="/etc/nginx"

# substitute $WORKER_PROCESSES into OpenResty configuration
# Applying the substitution in this way means that the default file is valid as it is.

if [ -n "$WORKER_PROCESSES" ]; then

  # sed supports multiple commands using the -e option

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

