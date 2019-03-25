#!/bin/sh

# Bash-strict-mode
IFS=$'\n\t'
set -euo pipefail

# Arguments to be supplied by build invocation (Docker Compose)
echo "PWD: " $(pwd)
echo "FROM: $FROM"
echo "USER: $USER ($UID)"
echo "BUILD_SCRIPT: $BUILD_SCRIPT"
echo "BUILD_CONFIG: $BUILD_CONFIG"

# CONSTANTS & SOURCES
source /build/urls.sh && cat /build/urls.sh

set -x

apk add --virtual .fat-stuff bash build-base curl linux-headers make perl unzip

cd /tmp
mkdir -p luarocks && curl -fSL ${URL_LUAROCKS} | tar xz --strip-components=1 -C luarocks

cd luarocks
./configure \
        --prefix=/usr/local/openresty/luajit \
        --with-lua=/usr/local/openresty/luajit \
        --lua-suffix=jit-2.1.0-beta3 \
        --with-lua-include=/usr/local/openresty/luajit/include/luajit-2.1

make build
make install

apk add --virtual .gettext gettext

mv /usr/bin/envsubst /tmp/

runDeps="$(scanelf --needed --nobanner /tmp/envsubst \
            | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
            | sort -u \
            | xargs -r apk info --installed \
            | sort -u \
  )"

apk add $runDeps

apk del .gettext

mv /tmp/envsubst /usr/local/bin/

# Add LuaRocks paths
# If OpenResty changes, these may need updating:
#    /usr/local/openresty/bin/resty -e 'print(package.path)'
#    /usr/local/openresty/bin/resty -e 'print(package.cpath)'

echo 'export LUA_PATH="/usr/local/openresty/site/lualib/?.ljbc;/usr/local/openresty/site/lualib/?/init.ljbc;/usr/local/openresty/lualib/?.ljbc;/usr/local/openresty/lualib/?/init.ljbc;/usr/local/openresty/site/lualib/?.lua;/usr/local/openresty/site/lualib/?/init.lua;/usr/local/openresty/lualib/?.lua;/usr/local/openresty/lualib/?/init.lua;./?.lua;/usr/local/openresty/luajit/share/luajit-2.1.0-beta3/?.lua;/usr/local/share/lua/5.1/?.lua;/usr/local/share/lua/5.1/?/init.lua;/usr/local/openresty/luajit/share/lua/5.1/?.lua;/usr/local/openresty/luajit/share/lua/5.1/?/init.lua"' > /etc/profile.d/lua_path.sh
echo 'export LUA_CPATH="/usr/local/openresty/site/lualib/?.so;/usr/local/openresty/lualib/?.so;./?.so;/usr/local/lib/lua/5.1/?.so;/usr/local/openresty/luajit/lib/lua/5.1/?.so;/usr/local/lib/lua/5.1/loadall.so;/usr/local/openresty/luajit/lib/lua/5.1/?.so"' > /etc/profile.d/lua_cpath.sh

echo "Cleaning up.."

rm -rf /tmp/*
apk del -v .build-dependencies || true
rm -rf /var/cache/apk/*
rm -rf /build
