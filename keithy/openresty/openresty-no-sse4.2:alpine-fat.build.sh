#!/bin/env bash

sudo docker build --no-cache -t registry.gitlab.com/keithy/angelbox/openresty-no-sse4.2:alpine-fat \
    --build-arg FROM=registry.gitlab.com/keithy/angelbox/openresty-no-sse4.2:alpine \
    --build-arg BUILD_ENV=default.env \
    --build-arg BUILD_SCRIPT=build-alpine-fat.sh \
    --build-arg BUILD_CONFIG=config-no-sse4.2.sh \
    --build-arg UID=83 \
    --build-arg USER=resty \
    . 



