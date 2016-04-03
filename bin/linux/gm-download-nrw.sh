#!/bin/bash

echo "Preparing to download Natural Resources Wales LiDAR..."

targetDir="/vagrant/source/eagg/"
targetTile=`echo $1 | tr '[:lower:]' '[:upper:]'`
targetFile="2m_res_${targetTile}_dtm.zip"
urlBase="http://lle.blob.core.windows.net/lidar/"

echo "Requesting header data for ${urlBase}${targetFile}..."
statusCount=`curl -I "$targetDir/$targetFile" "${urlBase}${targetFile}" | grep -c "200 OK" 2> /dev/null`

if [ $statusCount -ge 1 ]; then
	echo "Downloading "${targetFile}"..."
	curl -o "$targetDir/$targetFile" "${urlBase}${targetFile}"
fi

echo "--> Downloads are complete."
