#!/bin/env bash

[[ -z "$4" ]] && echo "Parameter 1: [php_base|php_fully-loaded]   - BUILD_ENV configuration " && exit
[[ -z "$4" ]] && echo "Parameter 2: [3.8|3.9]    - alpine version " && exit
[[ -z "$4" ]] && echo "Parameter 3: [7.2|7.3]    - php version " && exit
[[ -z "$4" ]] && echo "Parameter 4: [build|push|exec|build+push+exec] - action(s)"

# If the php version is "latest" or includes an update component, build from sources, 
# otherwise use published packages.
PHP_VERS="$3"

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

TAG="registry.gitlab.com/keithy/angelbox/${1}:alpine${2}-php${PHP_VERS}"
 
# frolvlad/alpine-glibc:alpine-3.8_glibc-2.27 \
[[ "$4" == *build* ]] && sudo docker build --no-cache -t "$TAG" \
    --build-arg FROM=alpine:${2} \
    --build-arg BUILD_ENV="/build/options/${1}.env" \
    --build-arg BUILD_SCRIPT="/build/alpine-$SRC/build-alpine3.x+php7.x.sh ${2} ${PHP_VERS}" \
    --build-arg BUILD_CONFIG="/build/alpine/config-development.sh" \
    --build-arg ON_FAIL=true \
    --build-arg UID=82 \
    --build-arg USER=www-data \
    . 
# check for successful build before pushing
[[ "$4" == *push* ]] && sudo docker run -ti --rm --entrypoint "/bin/sh" $TAG -c '[[ -f \.SUCCESS ]]' && \
    sudo docker push "$TAG"

[[ "$4" == *exec* ]] &&  sudo docker run -u 0 --rm -it "$TAG"

exit 0


