#!/bin/bash

echo "Preparing to download EA Geomatics Group LiDAR..."

targetDir=/vagrant/source/eagg/
targetMask=$1
targetType=$2

if [ -z "$targetType" ]; then 
	targetType="DTM"; 
fi

echo "Requesting index data..."
IFS=$'\n'; for f in `curl 'http://www.geostore.com/environment-agency/rest/product/OS_GB_10KM/'${targetMask} | python -c """
import json, sys, re
obj = json.load(sys.stdin)
pattern = re.compile('^LIDAR-${targetType}-2M-[A-Z][A-Z][0-9][0-9]\.zip$')
for i in range(len(obj)):
	if pattern.match(obj[i]['fileName']): 
		print obj[i]['fileName'] + ':' + obj[i]['guid']
"""`
do
	IFS=':' read -ra downloadData <<< "$f"
	echo "Downloading "${downloadData[0]}" with GUID "${downloadData[1]}"..."
	curl -o "$targetDir/${downloadData[0]}" "http://www.geostore.com/environment-agency/rest/product/download/${downloadData[1]}"
done

echo "--> Downloads are complete."
