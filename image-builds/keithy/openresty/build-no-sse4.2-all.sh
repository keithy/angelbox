
export REPO="registry.gitlab.com/keithy/angelbox"
# No extras added or built - testing only

./docker-build-openresty.sh alpine 3.8 no-sse4.2 std none build+push
./docker-build-openresty.sh alpine 3.8 no-sse4.2 fat none build+push
./docker-build-openresty.sh alpine 3.8 no-sse4.2 fat autossl build+push
./docker-build-openresty.sh alpine 3.8 no-sse4.2 std autossl build+push

./docker-build-openresty.sh alpine 3.9 no-sse4.2 std none build+push
./docker-build-openresty.sh alpine 3.9 no-sse4.2 fat none build+push
./docker-build-openresty.sh alpine 3.9 no-sse4.2 fat autossl build+push
./docker-build-openresty.sh alpine 3.9 no-sse4.2 std autossl build+push

 