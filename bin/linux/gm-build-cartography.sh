#!/bin/bash

echo "Preparing to build zone database..."

binDir=/vagrant/bin/linux
cartoDir=/vagrant/source/cartography
iconDir=/vagrant/source/icons

symbolLargePixelSize=50
symbolSmallPixelSize=35
symbolSurveyColour="#000000"
symbolStructureColour="#505050"

symbolNCNColour="#E35D5D"
symbolRCNColour="#5050e0"
symbolFootColour="#70a050"

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
convert -size 500x500 \
		xc:transparent \
		-fill yellow \
		-stroke black \
		-strokewidth 20 \
		-draw "circle 250,250 250,450" \
        "rail-station.png"

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

echo "--> Cycling network: National..."
convert -size ${symbolLargePixelSize}x${symbolLargePixelSize} \
		-density 1200 \
		-background none \
		-fill "red" \
		-opaque black \
		"$iconDir/cycle-route/bicycle.svg" \
        "route-ncn.png"
		
echo "--> Cycling network: National..."
convert -size 250x250 \
		xc:transparent \
		-fill "${symbolNCNColour}" \
		-draw "circle 125,125 125,240" \
        "route-dot-ncn.png"

echo "--> Cycling network: Regional..."
convert -size 250x250 \
		xc:transparent \
		-fill "${symbolRCNColour}" \
		-draw "circle 125,125 125,240" \
        "route-dot-rcn.png"
		
echo "--> Walking trail..."
convert -size 250x250 \
		xc:transparent \
		-fill "${symbolFootColour}" \
		-draw "circle 125,125 125,240" \
        "route-dot-trail.png"
		
echo "--> Cycling network: National and regional..."
convert -size 500x250 \
		xc:transparent \
		-fill "${symbolNCNColour}" \
		-draw "circle 125,125 125,240" \
		-fill "${symbolRCNColour}" \
		-draw "circle 375,125 375,240" \
        "route-dot-ncn-rcn.png"
		
echo "--> Cycling network: Regional and trail..."
convert -size 500x250 \
		xc:transparent \
		-fill "${symbolRCNColour}" \
		-draw "circle 125,125 125,240" \
		-fill "${symbolFootColour}" \
		-draw "circle 375,125 375,240" \
        "route-dot-rcn-trail.png"
		
echo "--> Cycling network: National and trail..."
convert -size 500x250 \
		xc:transparent \
		-fill "${symbolNCNColour}" \
		-draw "circle 125,125 125,240" \
		-fill "${symbolFootColour}" \
		-draw "circle 375,125 375,240" \
        "route-dot-ncn-trail.png"
		
echo "--> Cycling network: National and regional and trail..."
convert -size 750x250 \
		xc:transparent \
		-fill "${symbolNCNColour}" \
		-draw "circle 125,125 125,240" \
		-fill "${symbolRCNColour}" \
		-draw "circle 375,125 375,240" \
		-fill "${symbolFootColour}" \
		-draw "circle 625,125 625,240" \
        "route-dot-ncn-rcn-trail.png"
		
echo "--> Build complete."
cd - > /dev/null
