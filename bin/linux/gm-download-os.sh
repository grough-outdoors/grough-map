#!/bin/bash

echo "Preparing to download OS OpenData products..."

echo "-----------------------------------"
echo "--> Downloading archives..."
echo "-----------------------------------"
cd /vagrant/source/os/

if [ ! -e source_email.txt ]; then
	echo "You need to request an OS OpenData download from the Ordnance Survey website."
	echo "Once you have done this, press any key, then copy and paste the email."
	echo ""
	echo "Press Ctrl+O and return to save the file. Press Ctrl+X to exit again."
	read -n 1 -s
	nano -w source_email.txt
fi

dos2unix source_email.txt
grep -oP 'Download link\: \K(http://[^\n]+)' source_email.txt | while read -r fileURL ; do
	fileName=`echo -n "$fileURL" | grep -oP '\/\K([^\/\?]+)' | tail -1 | xargs echo -n`
	fileDecoded=`echo -n "$fileURL" | python -c "import sys, urllib as ul; sys.stdout.write(ul.unquote(sys.stdin.read()))"`
	
	if [ $(find ./ -iname ${fileName} | wc -l) -eq 1 ]
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

cd - > /dev/null

echo "--> Download complete. Run gm-import-os."
