#!/bin/bash

# file implementation
set -x

cd $(readlink -f "${BASH_SOURCE[0]%/*}")

sudo echo "Authorize Sudo" || exit

# Obtain the location of the secrets set in $SECRETS
source .env

[ ! -d "$SECRETS" ] && echo "Creating Secrets Directory: $SECRETS" && mkdir -p "$SECRETS"
[ -f "$SECRETS/mysql_root_pass" ] && echo "Secrets Already Defined" && exit
cd "$SECRETS"

#mysql_root_pass
openssl rand -base64 12 > mysql_root_pass

#mysql_root_pass.cnf
printf "[client]\npassword=\"$(cat mysql_root_pass)\"\n" > mysql_root_pass.cnf

#mysql_manager_pass (initial user)
openssl rand -base64 12 > mysql_manager_pass

# checksum for external tool to be able to see if this directory has been changed
md5sum * > .md5sums

# Lockdown permissions
chmod -R u+r,a-w,o-rx .
chmod o+x,g+s .
chmod o+r ./.md5sums

# Protect even from superusers/root
# ISSUE:
# Docker bug - this prevents secrets from working?
# sudo chattr +i * 

cd -
echo "Secrets created and locked-down (read-only)"

if [[ -n "$SECRETS_BACKUP_LOCATION" ]]; then
  backup="$SECRETS_BACKUP_LOCATION/${CODE_RELEASE}/${DEPLOYMENT_STATUS}"
  sudo mkdir -p "$backup"
  sudo cp -R "$SECRETS" "$backup"

  echo "Backed up to: $backup"
fi

sudo chown 999:0 mysql_root_pass.cnf
sudo chown 999:0 mysql_manager_pass
sudo chown 999:0 mysql_root_pass.cnf

#docker swarm implementation

# openssl rand -base64 12 > /tmp/secret
# cat /tmp/secret | docker secret create mysql_root_pass -
# printf "[client]\npassword=\"$(cat /tmp/secret)\"\n" | docker secret create mysql_root_pass.cnf -
# rm /tmp/secret
# openssl rand -base64 12 | docker secret create mysql_manager_pass -
