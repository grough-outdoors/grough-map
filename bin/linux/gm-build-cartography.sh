#!/bin/bash

echo "Preparing to build zone database..."

binDir=/vagrant/bin/linux
cartoDir=/vagrant/source/cartography/

echo "-----------------------------------"
echo "--> Generating symbols..."
echo "-----------------------------------"

cd $cartoDir

echo "--> CRoW line gradient pattern..."
convert -size 50x50 \
        xc:none \
        -fill orange \
        -draw "rectangle 0,0 25,50" \
        -draw "rectangle 25,25 50,50" \
        -gravity North \
        -alpha on -channel a -evaluate multiply 0.2 \
        -background none \
        -extent 50x100 -resize 25x30 \
        -rotate 180 \
        crow-line.png

cd -
		
echo "--> Build complete."
