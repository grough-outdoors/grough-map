#!/bin/bash

echo "      Generating symbol..."

symbolType=`echo $1 | tr '[:lower:]' '[:upper:]'`
symbolText="$2"

binDir=/vagrant/bin/linux
targetDir=/vagrant/volatile/symbols
typefaceDir=/vagrant/source/typefaces
iconDir=/vagrant/source/icons

symbolNCNColour="red"
symbolRCNColour="#0047AB"

if [[ "$symbolType" != "NCN" && "$symbolType" != "RCN" ]]; then
	echo "Invalid symbol request."
	exit 1
fi

if [[ -z "$symbolText" ]]; then
	symbolSuffix=""
else
	symbolSuffix="-${symbolText}"
fi

if [[ "$symbolType" = "NCN" ]]; then
	solidColour="$symbolNCNColour"
fi

if [[ "$symbolType" = "RCN" ]]; then
	solidColour="$symbolRCNColour"
fi

mkdir "${targetDir}" > /dev/null 2> /dev/null
cd "${targetDir}"

convert -size 100x100 \
		-background "${solidColour}" \
		-density 1200 \
		-fill "transparent" \
		"$iconDir/cycle-route/bicycle.svg"  \
		-resize 300x300 \
		-crop 300x250+0+25 \
		-fuzz 5% \
		-transparent black \
		-gravity west \
		-background transparent \
		-extent 1500x300 \
		-alpha set \
	    -font "${typefaceDir}/OpenSans-Bold.ttf" \
		-pointsize 13 \
		-fill "${solidColour}" \
		-stroke '#FFFFFF60' \
		-strokewidth 50 \
		-annotate +330+0 "${symbolText}" \
		-strokewidth 0 \
		-stroke none \
		-annotate +330+0 "${symbolText}" \
		-trim \
		"symbol-${symbolType}${symbolSuffix}.png"

cd - > /dev/null
echo "      Done."
