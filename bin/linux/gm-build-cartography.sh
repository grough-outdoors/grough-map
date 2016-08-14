#!/bin/bash

echo "Preparing to build zone database..."

binDir=/vagrant/bin/linux
cartoDir=/vagrant/source/cartography
iconDir=/vagrant/source/icons

symbolLargePixelSize=50
symbolSmallPixelSize=35
symbolSurveyColour="#000000"
symbolStructureColour="#505050"

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
        "crow-line.png"

echo "--> Boundary stone..."
echo "    Not yet available"

echo "--> Cairn..."
echo "    Not yet available"

echo "--> Campsite..."
echo "    Not yet available"

echo "--> Flagpole..."
convert -size ${symbolSmallPixelSize}x${symbolSmallPixelSize} \
		-density 1200 \
		-background none \
		-fill "${symbolStructureColour}" \
		-opaque black \
		"$iconDir/flagpole/flagpole.svg" \
        "flagpole.png"

echo "--> Fountain..."
echo "    Not yet available"

echo "--> Lighthouse..."
convert -size ${symbolSmallPixelSize}x${symbolSmallPixelSize} \
		-density 1200 \
		-background none \
		-fill "${symbolStructureColour}" \
		-opaque black \
		"$iconDir/lighthouse/lighthouse.svg" \
        "lighthouse.png"

echo "--> Mast..."
echo "    Not yet available"

echo "--> Monument..."
convert -size ${symbolSmallPixelSize}x${symbolSmallPixelSize} \
		-density 1200 \
		-background none \
		-fill "${symbolStructureColour}" \
		-opaque black \
		"$iconDir/monument/monument.svg" \
        "monument.png"

echo "--> Picnic site..."
convert -size ${symbolSmallPixelSize}x${symbolSmallPixelSize} \
		-density 1200 \
		-background none \
		-fill "${symbolStructureColour}" \
		-opaque black \
		"$iconDir/picnic-site/picnic-site.svg" \
        "picnic-site.png"

echo "--> Railway stations..."
echo "    Not yet available"

echo "--> Shelter..."
convert -size ${symbolSmallPixelSize}x${symbolSmallPixelSize} \
		-density 1200 \
		-background none \
		-fill "${symbolStructureColour}" \
		-opaque black \
		"$iconDir/shelter/shelter.svg" \
        "shelter.png"

echo "--> Survey point..."
convert -size ${symbolLargePixelSize}x${symbolLargePixelSize} \
		-density 1200 \
		-background none \
		-fill "${symbolSurveyColour}" \
		-opaque black \
		"$iconDir/survey-point/triangle.svg" \
        "survey-point.png"

echo "--> Towers..."
echo "    Not yet available"
		
echo "--> Build complete."
cd - > /dev/null
