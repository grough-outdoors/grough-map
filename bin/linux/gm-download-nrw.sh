#!/bin/bash

echo "Preparing to download Natural Resources Wales LiDAR..."

targetDir="/vagrant/source/eagg/"
targetTile=`echo $1 | tr '[:lower:]' '[:upper:]'`
targetType=`echo $2 | tr '[:upper:]' '[:lower:]'`
targetFile="2m_res_${targetTile}_${targetType}.zip"
urlBase="http://lle.blob.core.windows.net/lidar/"

mkdir "$targetDir" > /dev/null 2> /dev/null

echo "Requesting header data for ${urlBase}${targetFile}..."
statusCount=`curl -I "$targetDir/$targetFile" "${urlBase}${targetFile}" | grep -c "200 OK" 2> /dev/null`

if [ $statusCount -ge 1 ]; then
	echo "Downloading "${targetFile}"..."
	curl -o "$targetDir/$targetFile" "${urlBase}${targetFile}"
fi

echo "--> Downloads are complete."
