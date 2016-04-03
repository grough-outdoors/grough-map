#!/bin/bash

tileName=`echo $1 | tr '[:lower:]' '[:upper:]'`

binDir="/vagrant/bin/linux/"
terrainDir="/vagrant/source/terrain-composite/grid/"
outputDir="/vagrant/product/"
terrainCommand="$binDir/gm-build-terrain.sh"
mapnikDir="$binDir/Mapnik/"
mapnikOutputDir="$mapnikDir/output/"
mapnikCommand="$mapnikDir/generate.py"
currentDir=`pwd`

# TODO: Allow wildcard tile generation

if [ -z "$tileName" ]; then
	echo "Must supply tile name, e.g. NZ26"
	exit 1
else
	echo "Using tile name $tileName"
fi

if [ ! -e "$terrainDir/${tileName}.img" ]; then
	echo "No terrain data found for this tile. Attempting to generate."
	$terrainCommand $tileName
	if [ ! -e "$terrainDir/${tileName}.img" ]; then
		echo "Unable to generate terrain data. Cannot continue."
		exit 1
	fi
else
	echo "Identified suitable terrain data for this tile."
fi

echo "Starting map generation process..."
cd $mapnikDir
$mapnikCommand $tileName

echo "Moving output..."
mv "$mapnikOutputDir/$tileName.png" "$outputDir"

cd $currentDir
