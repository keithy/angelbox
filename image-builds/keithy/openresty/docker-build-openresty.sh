#!/bin/bash

NAME="openresty"
REPO="${REPO:-registry.gitlab.com/keithy/angelbox}"
 
if [[ -z "$6" ]]; then
	echo " Parameter 1: Distribution               [alpine]"
	echo " Parameter 2: Version                    [3.8|3.9]"
	echo " Parameter 3: Compilation configuration  [std|no-sse4.2]"
	echo " Parameter 4: Fat (LuaRocks build tools) [std|fat]"
	echo " Parameter 5: Additions                  [none|autossl]"
	echo " Parameter 6(last): actions [build|push|exec|tag|build+push+exec]"
fi

DIST=${1}
DIST_VERS=${2}

[[ "${3}" == "std" ]] && CCONFIG="" || CCONFIG="-${3}"
[[ "${4}" == "std" ]] && TOOLS="" || TOOLS="-${4}"
[[ "${5}" == "none" ]] && ADDITIONS="" || ADDITIONS="_${5}"
X_TAG=""

for actions; do true; done

set  -u

TAG="${REPO}/${NAME}:${DIST}${DIST_VERS}${CCONFIG}${TOOLS}${ADDITIONS}"


[[ "$actions" == *build* ]] && sudo docker build --no-cache -t "$TAG" \
    --build-arg FROM=${DIST}:${DIST_VERS} \
    --build-arg BUILD_SCRIPT="/build/build-${DIST}${TOOLS}${ADDITIONS}.sh ${DIST_VERS}" \
    --build-arg BUILD_CONFIG=/build/config${CCONFIG:--default}.sh \
    --build-arg UID=0 \
    --build-arg USER=root \
    --build-arg ON_FAIL=true \
    . 

# check for successful build before pushing
[[ "$actions" == *push* ]] && \
    sudo docker run -ti --rm --entrypoint "/bin/sh" $TAG -c '[[ -f \.SUCCESS ]]' && \
    sudo docker push "$TAG"

[[ "$actions" == *exec* ]] &&  sudo docker run -u 0 --rm -it "$TAG" sh

[[ "$actions" == *tag* ]] && echo "$TAG"

exit 0
