# No extras added or built - testing only

./alpine3.x_php7.x.sh php_none 3.9 7.3 build
./alpine3.x_php7.x.sh php_none 3.8 7.3 build
./alpine3.x_php7.x.sh php_none 3.8 7.2 build

# Aim for parity with official php:7.x-cli-alpine

./alpine3.x_php7.x.sh php_cli 3.9 7.3 build+push
./alpine3.x_php7.x.sh php_cli 3.8 7.3 build+push
./alpine3.x_php7.x.sh php_cli 3.8 7.2 build+push

# Aim for parity with official php:7.x-fpm-alpine

./alpine3.x_php7.x.sh php_fpm 3.9 7.3 build+push
./alpine3.x_php7.x.sh php_fpm 3.8 7.3 build+push
./alpine3.x_php7.x.sh php_fpm 3.8 7.2 build+push

# All extras

./alpine3.x_php7.x.sh php_all 3.9 7.3 build
./alpine3.x_php7.x.sh php_all 3.8 7.3 build
./alpine3.x_php7.x.sh php_all 3.8 7.2 build

# Aim for parity with official php:7.x-fpm-alpine
# But with swoole instead

./alpine3.x_php7.x.sh php_swoole 3.9 7.3 build+push
./alpine3.x_php7.x.sh php_swoole 3.8 7.3 build+push
./alpine3.x_php7.x.sh php_swoole 3.8 7.2 build+push

# A basic working image with
# mysql/pdo/composer/redis

./alpine3.x_php7.x.sh php_base 3.9 7.3 build+push
./alpine3.x_php7.x.sh php_base 3.8 7.3 build+push
./alpine3.x_php7.x.sh php_base 3.8 7.2 build+push

# Develpers image with everything for mariaDB except things definitely not needed
# i.e. not postgres mcrypt apache litespeed cgi ftp mysql-client mysql dev soap xmlrpc

./alpine3.x_php7.x.sh php_dev_mysql 3.9 7.3 build+push
./alpine3.x_php7.x.sh php_dev_mysql 3.8 7.3 build+push
./alpine3.x_php7.x.sh php_dev_mysql 3.8 7.2 build+push
