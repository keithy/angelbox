#!/bin/sh

echo "Cleaning up.."

docker-php-source delete
pecl clear-cache
rm -rf /tmp/pear
rm -rf /tmp/src
apk del -v build-dependencies
rm -rf /var/cache/apk/*
# tidy up
rm -rf /build 



