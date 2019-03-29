#!/bin/env bash

set -ex

NAME="openresty"
REPO="${REPO:-registry.gitlab.com/keithy/angelbox}"
 
if [[ -z "$6" ]]; then
	echo " Parameter 1: Distribution               [alpine]"
	echo " Parameter 2: Version                    [3.8|3.9]"
	echo " Parameter 3: Compilation configuration  [std|no-sse4.2]"
	echo " Parameter 6(last): actions [build|push|exec|tag|build+push+exec]"
fi

DIST=${1}
DIST_VERS=${2}

[[ "${3}" == "std" ]] && CCONFIG="" || CCONFIG="-${3}"

for actions; do true; done

set  -u

TAG="${REPO}/${NAME}:buildahs-${DIST}${DIST_VERS}"

if [[ "$actions" == *build* ]]; then

	image=$(buildah from $DIST:$DIST_VERS)
	buildah config --entrypoint  '["/entrypoint.sh"]' $image
	buildah config --cmd  '["/usr/local/openresty/bin/openresty", "-g", "daemon off;"]' $image
	buildah config --created-by "keithy" $image
	buildah config --author "keithy@consultant.com" $image
	buildah config --label name=resty_autossl $image

	buildah config --env FROM=alpine $image
	buildah config --env BUILD_SCRIPT=/build/build+base.sh $image
	buildah config --env BUILD_ENV=default.env $image    
	buildah config --env BUILD_CONFIG=/build/config${CCONFIG:--default}.sh $image
	buildah config --env UID=0 $image
	buildah config --env USER=root $image
    
	buildah inspect $image
 
 	buildah copy $image root /

	buildah run $image -- /build/build+base.sh ${DIST_VERS}
	buildah commit $image openresty-base

	buildah run $image -- /build/build+fat.sh
	buildah commit $image openresty-fat

	buildah run $image -- /build/build+autossl.sh
	buildah commit $image openresty-fat_autossl

	buildah run $image -- /build/clean-fat.sh
	buildah commit $image openresty_autossl

	openresty=$(buildah from openresty-base)
	buildah run $openresty -- /build/clean-std.sh
	buildah commit $openresty openresty-base

	openresty=$(buildah from openresty-fat)
	buildah run $openresty -- /build/clean-std.sh
	buildah commit $openresty openresty-fat

	openresty=$(buildah from openresty-fat_autossl)
	buildah run $openresty -- /build/clean-std.sh
	buildah commit $openresty  openresty-fat_autossl

	openresty=$(buildah from openresty_autossl)
	buildah run $openresty -- /build/clean-std.sh
	buildah commit $openresty openresty_autossl
fi

# check for successful build before pushing
if [[ "$actions" == *push* ]]; then

    buildah push --creds keithy openresty-base ${TAG}
    buildah push --creds keithy openresty-base-fat ${TAG}-fat
    buildah push --creds keithy openresty-base-fat_autossl ${TAG}-fat_autossl 
    buildah push --creds keithy openresty-base_autossl  ${TAG}_autossl 
fi

#[[ "$actions" == *exec* ]] &&  sudo docker run -u 0 --rm -it "$TAG" sh

[[ "$actions" == *tag* ]] && echo "$TAG"

exit 0
