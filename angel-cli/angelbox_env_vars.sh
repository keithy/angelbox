#!/bin/bash

echo "######################################################################" >> $1
echo "## From: ANGEL_<item>" >> $1
printf "ANGEL=" >> $1
printf "%s " $(sed -n 's/^ANGEL_\(.*\)/\1/pg' "$1") >> $1
echo >> $1
echo >> $1

## Append miscellaneous items
echo "## Miscellaneous" >> $1

myip=$(curl -sL ipecho.net/plain)
echo "MYIP=${myip}" >> $1