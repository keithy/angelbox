echo "Cleaning Up..."

apk del .build-dependencies || true 
rm -rf /tmp/*
rm -rf /var/cache/apk/*
rm -rf /build

