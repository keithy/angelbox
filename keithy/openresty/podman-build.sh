#!/bin/env bash

podman build --no-cache -t keithy/openresty-no-sse4.2:alpine-fat \
    --build-arg FROM=alpine:3.8 \
    --build-arg BUILD_ENV=default.env \
    --build-arg BUILD_SCRIPT=build-alpine-fat.sh \
    --build-arg BUILD_CONFIG=config-no-sse4.2.sh \
    --build-arg UID=83 \
    --build-arg USER=resty \
    . 

