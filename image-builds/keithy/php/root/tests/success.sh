#!/bin/sh

echo "Build Success"

source "/build/CLEAN.sh"

#run tests here

touch /.SUCCESS

rm -rf /tests
