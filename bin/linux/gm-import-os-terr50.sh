#!/bin/bash

scriptDir=`dirname ${BASH_SOURCE[0]}`
targetDir="/vagrant/source/os-terrain/"

echo "     --> Importing OS Terrain 50..."
echo "     --> Finding ZIP archives..."
IFS=$'\n'; for f in $(find ./ -name '*OST50GRID*.zip')
do
	echo "        --> Extracting $f..."
	unzip "$f"
	echo "        --> Finding ASCII grids..."
	IFS=$'\n'; for g in $(find ./ -name '*.asc')
	do
		echo "           --> Archiving $g..."
		mv "$g" "$targetDir"
	done
done
echo "     --> Processing complete."
