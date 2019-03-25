#!/bin/env bash

TAG="registry.gitlab.com/keithy/angelbox/openresty-no-sse4.2:alpine"

[[ "$1" == "push" ]] &&  sudo docker push "$TAG"

[[ "$1" == "build" ]] && sudo docker build --no-cache -t "$TAG" \
    --build-arg FROM=alpine:3.8 \
    --build-arg BUILD_SCRIPT=build-alpine.sh \
    --build-arg BUILD_CONFIG=config-no-sse4.2.sh \
    --build-arg UID=83 \
    --build-arg USER=resty \
    . 

exit 0


