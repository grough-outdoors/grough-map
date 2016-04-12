#!/bin/bash

tileName=`echo $1 | tr '[:lower:]' '[:upper:]'`
extraOption=`echo $2 | tr '[:lower:]' '[:upper:]'`

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

if [ -z "$extraOption" ]; then
	echo "Moving output..."
	mv "$mapnikOutputDir/$tileName.png" "$outputDir"
else
	if [ "$extraOption" != "geotiff" ]; then
		echo "Converting output..."
		convert "$mapnikOutputDir/$tileName.png" -compress LZW "$outputDir/$tileName.tiff"
		echo "Assigning georeference..."
		gdal_edit.py -a_srs EPSG:27700 -a_ullr `gdalinfo ${terrainDir}/${tileName}.img | awk '/(Upper Left)|(Lower Right)/' | awk '{gsub(/,|\)|\(/," ");print $3 " " $4}' | sed ':a;N;$!ba;s/\\n/ /g'` "$outputDir/$tileName.tiff"
		rm -f "$mapnikOutputDir/$tileName.png"
	fi
fi

cd $currentDir
