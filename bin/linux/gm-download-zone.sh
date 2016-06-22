#!/bin/bash

echo "Preparing to download Natural England data..."

targetDir=/vagrant/source/natural-england/
mkdir "$targetDir" > /dev/null 2> /dev/null
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

echo "Preparing to download Natural Resources Wales products..."

mkdir /vagrant/source/nrw/
cd /vagrant/source/nrw/

echo "Downloading CRoW access layer..."
curl -L -o "CRoW_Access_Land.zip" "http://lle.gov.wales/catalogue/item/OpenAccessCountrysideRightsOfWayActCROWDedicatedLand.zip"
echo "Downloading National Parks..."
curl -L -o "National_Parks.zip" "http://lle.gov.wales/catalogue/item/NationalParks.zip"
echo "Downloading Country Parks..."
curl -L -o "Country_Parks.zip" "http://lle.gov.wales/catalogue/item/ProtectedSitesCountryParks.zip"
cd -

echo "--> Downloads are complete."
