#!/bin/bash

cd /tmp

grassFilesFound=$(ls grass*.tar.gz | wc -l)
echo "Found ${grassFilesFound} instance(s) of GRASS GIS files downloaded."

if [[ "${grassFilesFound}" -gt 0 ]]; then
	echo "Reinstalling pre-existing GRASS download..."
	shellFile=(*.sh)
	tarFile=(*.tar*)
	echo "   Shell file: ${shellFile}"
	echo "   Tar file: ${tarFile}"
else
	echo "Downloading new copy of GRASS..."
	rm -rf grass*
	shellFile=`curl https://grass.osgeo.org/grass70/binary/linux/snapshot/ | grep '\.sh' | grep -o '<a.*href=.*>' | sed 's/<a href="//g' | sed 's/\".*$//'`
	tarFile=`curl https://grass.osgeo.org/grass70/binary/linux/snapshot/ | grep '\.tar' | grep -o '<a.*href=.*>' | sed 's/<a href="//g' | sed 's/\".*$//'`
	wget "https://grass.osgeo.org/grass70/binary/linux/snapshot/$shellFile"
	wget "https://grass.osgeo.org/grass70/binary/linux/snapshot/$tarFile"
fi

sudo rm -rf /usr/local/grass7*
chmod +x "$shellFile"
sudo "./$shellFile" "$tarFile"

cd - > /dev/null
