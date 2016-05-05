#!/bin/bash

echo "Preparing to archive built feature data..."
dataType=`echo $1 | tr '[:lower:]' '[:upper:]'`

echo "-----------------------------------"
echo "--> Storing data..."
echo "-----------------------------------"
cd /vagrant/archive/

if [ "$dataType" = "ELEVATION" ]; then
	echo "--> Storing elevation..."
	pg_dump -Ugrough-map grough-map -h 127.0.0.1 -Fc --compress=9 -t elevation -a > elevation.bak
	echo "--> Storing elevation sources..."
	pg_dump -Ugrough-map grough-map -h 127.0.0.1 -Fc --compress=9 -t elevation_source -a > elevation_source.bak
else
	echo "Unrecognised archive request."
fi

echo ""
echo "Export complete. Run gm-restore-data to return."
cd - > /dev/null 2> /dev/null
