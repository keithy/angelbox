
export REPO="registry.gitlab.com/keithy/angelbox"
# No extras added or built - testing only

./alpine3.x_php7.x.sh php_none 3.9 7.3 build
./alpine3.x_php7.x.sh php_none 3.8 7.3 build
./alpine3.x_php7.x.sh php_none 3.8 7.2 build

# Aim for parity with official php:7.x-cli-alpine

./alpine3.x_php7.x.sh php_cli 3.9 7.3 build
./alpine3.x_php7.x.sh php_cli 3.8 7.3 build
./alpine3.x_php7.x.sh php_cli 3.8 7.2 build

# Aim for parity with official php:7.x-fpm-alpine

./alpine3.x_php7.x.sh php_fpm 3.9 7.3 build
./alpine3.x_php7.x.sh php_fpm 3.8 7.3 build
./alpine3.x_php7.x.sh php_fpm 3.8 7.2 build

# All extras - testing compilations only
# note doesn't test swoole_pecl

./alpine3.x_php7.x.sh php_all 3.9 7.3 build
./alpine3.x_php7.x.sh php_all 3.8 7.3 build
./alpine3.x_php7.x.sh php_all 3.8 7.2 build

# Aim for parity with official php:7.x-fpm-alpine
# But with swoole instead

./alpine3.x_php7.x.sh php_swoole 3.9 7.3 build+push
./alpine3.x_php7.x.sh php_swoole 3.8 7.3 build
./alpine3.x_php7.x.sh php_swoole 3.8 7.2 build

# Aim for parity with official php:7.x-fpm-alpine
# But with swoole built from pecl instead
./alpine3.x_php7.x.sh php_swoole 3.9 7.3 swo4.3.1 build+push 
./alpine3.x_php7.x.sh php_swoole 3.8 7.3 swo4.3.1 build 
./alpine3.x_php7.x.sh php_swoole 3.8 7.2 swo4.3.1 build 

# A basic production fpm image with
# mysql/pdo/redis/fpm

./alpine3.x_php7.x.sh php_mysql 3.9 7.3 build+push
./alpine3.x_php7.x.sh php_mysql 3.8 7.3 
./alpine3.x_php7.x.sh php_mysql 3.8 7.2 

# Develpers image with everything for mariaDB except things definitely not needed
# i.e. not postgres mcrypt apache litespeed cgi ftp mysql-client mysql dev soap xmlrpc
# Includes SWOOLE, PHALCON, SCALAR_OBJECTS, DS!

./alpine3.x_php7.x.sh php_mysql 3.9 7.3 dev build+push 
./alpine3.x_php7.x.sh php_mysql 3.9 7.3 swo4.3.1 build+push 
./alpine3.x_php7.x.sh php_mysql 3.9 7.3 dev-swo4.3.1 build+push 
