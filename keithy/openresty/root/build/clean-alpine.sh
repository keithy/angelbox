#!/bin/sh

echo "Cleaning up.."

rm -rf /tmp/*
apk del -v .build-dependencies || true
rm -rf /var/cache/apk/*
rm -rf /build




