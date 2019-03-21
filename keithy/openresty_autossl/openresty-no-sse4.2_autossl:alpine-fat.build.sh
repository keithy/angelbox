#!/bin/env bash

TAG="registry.gitlab.com/keithy/angelbox/openresty-no-sse4.2_autossl:alpine-fat"

[[ "$1" == "push" ]] &&  sudo docker push "$TAG"

[[ "$1" == "build" ]] && sudo docker build --no-cache -t "$TAG" \
    --build-arg FROM=registry.gitlab.com/keithy/angelbox/openresty-no-sse4.2:alpine-fat \
    --build-arg BUILD_CLEAN=false \
    --build-arg UID=83 \
    --build-arg USER=resty \
    .

exit 0


