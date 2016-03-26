#!/bin/bash

echo "Preparing to download Natural England products..."

echo "-----------------------------------"
echo "--> Downloading archives..."
echo "-----------------------------------"
cd /vagrant/source/natural-england/

echo "Downloading CRoW act access layer..."
curl -o "crow_all.zip" "http://www.geostore.com/inspiredata/ea_inspire_shape_zipped/CROW_Access_Layer.zip"

echo "Downloading country parks..."
# TODO

echo "Downloading millennium greens..."
# TODO

echo "Downloading nature reserves..."
# TODO

echo "Downloading registered battlefields..."
# TODO

echo "Downloading registered parks and gardens..."
# TODO

echo "Downloading world heritage sites..."
# TODO

echo "-----------------------------------"
echo "--> Filing archive files..."
echo "-----------------------------------"
for z in *.zip
do
	IFS='_' read -ra FileComponents <<< "$z"
	echo "Filing $z..."
	mkdir ${FileComponents[0]} > /dev/null 2> /dev/null
	mv "$z" "${FileComponents[0]}/"
done

echo "--> Download complete. Run gm-import-ne."
