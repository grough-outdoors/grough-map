#!/bin/bash

tileName=`echo $1 | tr '[:lower:]' '[:upper:]' | sed -e 's/[^A-Z0-9\%]//g'`

binDir="/vagrant/bin/linux/"
currentDir=`pwd`

if [ -z "$tileName" ]; then
	echo "Must supply tile name, e.g. NZ26"
	exit 1
else
	echo "Using tile mask $tileName"
fi

echo " --> Fetching matching tiles..."
IFS=$'\n'; for tileName in `psql -Ugrough-map grough-map -h 127.0.0.1 -A -t -c "SELECT tile_name FROM grid WHERE tile_name LIKE '${tileName}'"`
do
	echo "-----------------------"
	echo "  Processing $tileName"
	echo "-----------------------"
	"$binDir/gm-build-terrain-tile.sh" "$tileName"
done

cd $currentDir
