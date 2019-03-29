#!/bin/env bash

[[ -z "$3" ]] && echo " Parameter 1: [php_swoole|php_mysql|...] - BUILD_ENV configuration " && exit
[[ -z "$3" ]] && echo " Parameter 2: [3.8|3.9]                  - alpine version " && exit
[[ -z "$3" ]] && echo " Parameter 3: [7.2|7.3|latest]           - php version " && exit
[[ -z "$3" ]] && echo "[Parameter 4]: optional                  - append to tag"
[[ -z "$3" ]] && echo " Parameter 5: [build|push|exec|tag|build+push+exec] - action(s)"

for actions; do true; done

[[ "$actions" == "$5" ]] && X_TAG="-$4" || X_TAG="" 

# If the php version is "latest" or includes an update component, build from sources, 
# otherwise use published packages.
PHP_VERS="$3"
ALP_VERS="$2"
NAME="$1"

#latest finds the latest version of PHP available for download
case "$3" in 
  	latest)
       json=$(curl -sL "https://www.php.net/releases/?json&max=1&version=7")
       json=${json#*\"}
       PHP_VERS=${json%%\"*}
    ;;
  	*.*.*)
	SRC="src" 
    ;;
    *)
    SRC="apk"
esac
 
set  -u

REPO="${REPO:-registry.gitlab.com/keithy/angelbox}"
TAG="$REPO/${NAME}:alp${ALP_VERS}-php${PHP_VERS}${X_TAG}"
 
# frolvlad/alpine-glibc:alpine-3.8_glibc-2.27 \
[[ "$actions" == *build* ]] && sudo docker build --no-cache -t "$TAG" \
    --build-arg FROM=alpine:${ALP_VERS} \
    --build-arg BUILD_ENV="/build/options/${NAME}${X_TAG}.env" \
    --build-arg BUILD_SCRIPT="/build/alpine-$SRC/build-alpine3.x+php7.x.sh ${ALP_VERS} ${PHP_VERS} ${X_TAG}" \
    --build-arg BUILD_CONFIG="/build/alpine-$SRC/config-null.sh" \
    --build-arg ON_FAIL=true \
    --build-arg UID=82 \
    --build-arg USER=www-data \
    . 
# check for successful build before pushing
[[ "$actions" == *push* ]] && sudo docker run -ti --rm --entrypoint "/bin/sh" $TAG -c '[[ -f \.SUCCESS ]]' && \
    sudo docker push "$TAG"

[[ "$actions" == *exec* ]] &&  sudo docker run -u 0 --rm -it "$TAG"

[[ "$actions" == *tag* ]] && echo "$TAG"

exit 0

