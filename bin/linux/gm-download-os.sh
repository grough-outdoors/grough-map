#!/bin/bash

echo "Preparing to download OS OpenData products..."

echo "-----------------------------------"
echo "--> Downloading archives..."
echo "-----------------------------------"
cd /vagrant/source/os/
dos2unix source_email.txt
grep -oP 'Download link\: \K(http://[^\n]+)' source_email.txt | while read -r fileURL ; do
	fileName=`echo -n "$fileURL" | grep -oP '\/\K([^\/\?]+)' | tail -1 | xargs echo -n`
	fileDecoded=`echo -n "$fileURL" | python -c "import sys, urllib as ul; sys.stdout.write(ul.unquote(sys.stdin.read()))"`
	if [ -e $fileName ]
	then
		echo "Skipping $fileName -- already exists. Delete to redownload."
	else
		echo "Downloading $fileName"
		echo "... $fileDecoded"
		curl -o $fileName "$fileURL"
	fi
done

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

echo "--> Download complete. Run gm-import-os."
