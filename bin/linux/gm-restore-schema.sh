#!/bin/bash

echo "Preparing to restore main schema..."

fileBaseDir=/vagrant/source/schema/
binDir=../../bin/linux

echo "-----------------------------------"
echo "--> Restoring..."
echo "-----------------------------------"
cd $fileBaseDir
for d in *.sql
do
	echo " Found item '"$d"'"
	echo " --> Importing..."
	
	psql -Ugrough-map grough-map -h 127.0.0.1 -f $d > /dev/null 
done

echo "--> Restore complete."
