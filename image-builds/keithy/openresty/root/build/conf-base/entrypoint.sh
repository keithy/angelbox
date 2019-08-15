#!/bin/sh

source /etc/profile

if [ -n "$@" ]; then
  exec "$@"
fi

/usr/local/openresty/bin/openresty -g "daemon off;"

