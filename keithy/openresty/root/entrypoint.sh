#!/bin/env sh

if [ -n "$@" ]; then
  exec "$@"
fi

/usr/local/openresty/bin/openresty -g "daemon off;"

