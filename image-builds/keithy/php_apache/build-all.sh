
# Useful

docker rm target
docker run --name target php:apache &

docker exec -t -i  target docker-php-ext-install mysqli
docker commit target registry.gitlab.com/keithy/angelbox/php_apache:php7_mysqli
docker push registry.gitlab.com/keithy/angelbox/php_apache:php7_mysqli

docker exec -t -i  target pecl install xdebug
docker commit target registry.gitlab.com/keithy/angelbox/php_apache:php7_mysqli_xdebug
docker push registry.gitlab.com/keithy/angelbox/php_apache:php7_mysqli_xdebug

docker exec -t -i  target docker-php-ext-install pdo_mysql pdo
docker commit target registry.gitlab.com/keithy/angelbox/php_apache:php7_pdo_mysqli_xdebug
docker push registry.gitlab.com/keithy/angelbox/php_apache:php7_pdo_mysqli_xdebug

docker exec -t -i  target apt-get update
docker exec -t -i  target apt-get -y install libyaml-dev
docker exec -t -i  target pecl install yaml
docker exec -t -i  target sh -c 'echo "extension=yaml.so" > /usr/local/etc/php/conf.d/00-yaml.ini'
docker exec -t -i  target apt-get clean

docker commit target registry.gitlab.com/keithy/angelbox/php_apache:php7_pdo_mysqli_yaml_xdebug
docker push registry.gitlab.com/keithy/angelbox/php_apache:php7_pdo_mysqli_yaml_xdebug

#to verify which modules are loaded
docker exec -t -i  target php -m

docker stop target
docker rm target