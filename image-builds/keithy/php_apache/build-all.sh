
# Useful

docker run --name target php:apache &

docker exec -t -i  target docker-php-ext-install mysqli
docker commit target registry.gitlab.com/keithy/angelbox/php_apache:php7_mysqli
docker push registry.gitlab.com/keithy/angelbox/php_apache:php7_mysqli

docker exec -t -i  target pecl install xdebug
docker commit target registry.gitlab.com/keithy/angelbox/php_apache:php7_mysqli_xdebug
docker push registry.gitlab.com/keithy/angelbox/php_apache:php7_mysqli_xdebug

docker stop target
docker rm target