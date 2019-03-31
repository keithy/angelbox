#!/bin/bash

# This script generates a default set of secrets that angelbox can use for all of
# the servies that use them. This only needs to be run once, following installation.
#
# It will only re-generate secrets that are missing so will not overwrite existing files
# and this script can be safely re-run if a secret has been deleted or is missing.

# file implementation
set -x
cd $(readlink -f "${BASH_SOURCE[0]%/*}")

if (( $EUID != 0 )); then
    echo "Please run as root"
    exit
fi

# Obtain CODE_RELEASE from .env
CODE_RELEASE=$(grep SERVICES_FILE .env | xargs)
CODE_RELEASE="${CODE_RELEASE##*=}"
CODE_RELEASE="${CODE_RELEASE%.env}"
CODE_RELEASE="${CODE_RELEASE#./}"

# Obtain DEPLOYMENT_STATUS from .env
DEPLOYMENT_STATUS=$(grep DEPLOYMENT_STATUS .env | xargs)
DEPLOYMENT_STATUS="${DEPLOYMENT_STATUS##*=}"

# Obtain the location of the secrets, the last value of SECRETS in .env
SECRETS_BACKUP_LOCATION=$(grep SECRETS_BACKUP_LOCATION .env | xargs)
SECRETS_BACKUP_LOCATION=$(readlink -f "${SECRETS_BACKUP_LOCATION##*=}")

# Obtain the location of the secrets, the last value of SECRETS in .env
SECRETS=$(grep SECRETS .env | xargs)
SECRETS=$(readlink -f "${SECRETS##*=}")

if [ ! -d "$SECRETS" ]; then
  echo "Creating Secrets Directory: $SECRETS"
  mkdir -p "$SECRETS"
  chmod o+x,g+s "$SECRETS"
fi

cd "$SECRETS"

mkdir -p "$SECRETS/mysql"

if [ ! -f "$SECRETS/mysql/mysql_root_pass" ]; then

  #mysql_root_pass
  printf "%s" $(openssl rand -base64 12) > mysql/mysql_root_pass

fi

if [ ! -f "$SECRETS/mysql/mysql_root_pass.cnf" ]; then

  #mysql_root_pass.cnf
  printf "[client]\npassword=\"$(cat mysql/mysql_root_pass)\"\n" > mysql/mysql_root_pass.cnf
  
fi

if [ ! -f "$SECRETS/mysql/mysql_manager_pass" ]; then

  #mysql_manager_pass (initial user)
  printf "%s" $(openssl rand -base64 12) > mysql/mysql_manager_pass
  
fi

mkdir -p "$SECRETS/redis"

if [ ! -f "$SECRETS/redis/redis_password" ]; then

  printf "%s" $(openssl rand -base64 12) > redis/redis_pass

fi
 
# Lockdown permissions
chmod -R u+r,a-w,o-rx .
chmod o+r ./.md5sums

# Protect even from superusers/root
# ISSUE:
# Docker bug - this prevents secrets from working at all?
# sudo chattr +i * 

echo "Secrets created and locked-down (read-only)"

backup="$SECRETS_BACKUP_LOCATION/${CODE_RELEASE}/${DEPLOYMENT_STATUS}"
echo $backup

if [[ ! -d "$backup" ]]; then
 
  sudo mkdir -p "$backup"
  sudo cp -R "$SECRETS"/* "$backup"

  echo "Backed up to: $backup"
fi

# FIX PERMISSIONS

chown -R 999:0 mysql

[ ! -d php_apache ] && mkdir php_apache
cp -R mysql/* php_apache
chown -R 33:0 php_apache

[ ! -d php_fpm ] && mkdir php_fpm
cp -R mysql/* php_fpm
chown -R 82:0 php_fpm

# checksum for external tool to be able to see if this directory has been changed
md5sum */* > .md5sums
 
 
 
 
 




cd -

#docker swarm implementation

# openssl rand -base64 12 > /tmp/secret
# cat /tmp/secret | docker secret create mysql_root_pass -
# printf "[client]\npassword=\"$(cat /tmp/secret)\"\n" | docker secret create mysql_root_pass.cnf -
# rm /tmp/secret
# openssl rand -base64 12 | docker secret create mysql_manager_pass -
