#!/bin/bash

# file implementation
set -x

sudo echo "Authorize Sudo" || exit

# Obtain the location of the secrets set in $SECRETS
source .env

[ ! -d "$SECRETS" ] && echo "Secrets directory not found: $SECRETS" && exit
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
chmod -R u+r,a-w,o-rx "$SECRETS"
chmod o+x,g+s "$SECRETS"
chmod o+r "$SECRETS/.md5sums"

# Protect even from superusers/root
sudo chattr +i * 

cd -
echo "Secrets created and locked-down (read-only)"
echo "Backup with:"
echo "  sudo cp -R $SECRETS $SECRETS.backup"

#docker swarm implementation

# openssl rand -base64 12 > /tmp/secret
# cat /tmp/secret | docker secret create mysql_root_pass -
# printf "[client]\npassword=\"$(cat /tmp/secret)\"\n" | docker secret create mysql_root_pass.cnf -
# rm /tmp/secret
# openssl rand -base64 12 | docker secret create mysql_manager_pass -
