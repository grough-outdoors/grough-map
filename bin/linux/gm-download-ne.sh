#!/bin/bash

echo "Preparing to download Natural England data..."

targetDir=/vagrant/source/natural-england/

cd $targetDir
echo "Requesting catalogue data..."
IFS=$'\n'; for f in `curl 'http://www.geostore.com/environment-agency/rest/catalogue' | python -c """
import json, sys, re
obj = json.load(sys.stdin)
listMasks = [
	'National Parks \(England\)',
	'CRoW(.*)Access Layer',
	'Nature Reserves',
	'Country Parks',
	'National Trails',
	'Doorstep Greens',
	'Millennium Greens'
]
for i in range(len(obj)):
	for idx, regex in enumerate(listMasks):
		pattern = re.compile(regex)
		if pattern.match(obj[i]['descriptiveName']): 
			print obj[i]['formattedFiles']['ESRI_Shapefile']
"""`
do
	echo "Downloading ${f}..."
	curl -O "$f"
done
cd -

echo "--> Downloads are complete."
