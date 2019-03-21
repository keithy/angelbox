#!/bin/env bash

sudo docker build --no-cache -t registry.gitlab.com/keithy/angelbox/openresty-no-sse4.2:alpine \
    --build-arg FROM=alpine:3.8 \
    --build-arg BUILD_ENV=default.env \
    --build-arg BUILD_SCRIPT=build-alpine.sh \
    --build-arg BUILD_CONFIG=config-no-sse4.2.sh \
    --build-arg UID=83 \
    --build-arg USER=resty \
    . 



