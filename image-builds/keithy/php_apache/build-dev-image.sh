
# Just the last of the other images built in a single layer

docker rm target
docker run --name target php:apache &

docker exec -t -i  target docker-php-ext-install mysqli pdo_mysql pdo
 
docker exec -t -i  target apt-get update
docker exec -t -i  target apt-get -y install libyaml-dev

docker exec -t -i  target pecl install xdebug
docker exec -t -i  target pecl install yaml
docker exec -t -i  target sh -c 'echo "extension=yaml.so" > /usr/local/etc/php/conf.d/00-yaml.ini'
docker exec -t -i  target pecl install runkit
#docker exec -t -i  target sh -c 'echo "extension=yaml.so" > /usr/local/etc/php/conf.d/00-yaml.ini'

docker exec -t -i  target apt-get clean

docker commit target registry.gitlab.com/keithy/angelbox/php_apache:php7_pdo_mysqli_yaml_runkit_xdebug
docker push registry.gitlab.com/keithy/angelbox/php_apache:php7_pdo_mysqli_yaml_xdebug

#to verify which modules are loaded
docker exec -t -i  target php -m

docker stop target
docker rm target