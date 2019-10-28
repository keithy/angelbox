# Fedora tools to make stuff available on fedora atomic
# principally php composer
# The tricky bit is that this image needs a gitlab token
# we copy this in from /root/.composer given that this token
# has been manually obtained before

docker rm tools
docker run --name tools \
	--privileged --ipc=host --net=host --pid=host \
	-e HOST=/host -e NAME=tools -e IMAGE=fedora/tools \
	-v /run:/run -v /var/log:/var/log -v /etc/localtime:/etc/localtime \
	-v /:/host \
	-v /root/.composer:/root/.composer \
	fedora/tools sleep 1d &

sleep 1

docker exec -t -i  tools setenforce 0
docker exec -t -i  tools dnf install php-cli
 
docker exec -t -i  tools sh -c "curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer"

docker commit tools registry.gitlab.com/keithy/angelbox/fedora/tools:php7_composer
docker push registry.gitlab.com/keithy/angelbox/fedora/tools:php7_composer
	
#to verify which modules are loaded
docker exec -t -i  tools php -m

docker stop tools
docker rm tools

# composer install --ignore-platform-reqs --prefer-dist     

# 

docker run --name tools \
	--privileged --ipc=host --net=host --pid=host \
	-e HOST=/host -e NAME=tools -e IMAGE=registry.gitlab.com/keithy/angelbox/fedora/tools:php7_composer \
	-v /run:/run -v /var/log:/var/log -v /etc/localtime:/etc/localtime \
	-v /:/host \
	-v /root/.composer:/root/.composer \
	registry.gitlab.com/keithy/angelbox/fedora/tools:php7_composer \
	sh -c 'cd /host/home/eatbits/SITES/gitlab/release-test; composer install --ignore-platform-reqs --prefer-dist'
	
docker run --rm \
	-v /:/host -v /root/.composer:/root/.composer \
	registry.gitlab.com/keithy/angelbox/fedora/tools:php7_composer \
	composer install -d /host/home/eatbits/SITES/gitlab/release-test --ignore-platform-reqs --prefer-dist