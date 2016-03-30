#!/bin/bash

tileName=$1
targetResolution="2"
blendDistance=50
blendCells=$(($blendDistance/(10000 / 1600) - 1))
scratchDir="/vagrant/volatile/"
osTileDir="/vagrant/source/os-terrain/"
eaTileDir="/vagrant/source/eagg/"
targetDir="/vagrant/source/terrain-composite/"
currentDir=`pwd`

mkdir $targetDir/contours > /dev/null 2> /dev/null
mkdir $targetDir/grid > /dev/null 2> /dev/null
mkdir $targetDir/coverage > /dev/null 2> /dev/null

cd $scratchDir
rm -rf scratch > /dev/null 2> /dev/null
rm ${tileName}_Contours.*  > /dev/null 2> /dev/null
rm ${tileName}_Final.* > /dev/null 2> /dev/null
mkdir scratch

gdalbuildvrt -resolution highest -a_srs EPSG:27700 scratch/${tileName}.vrt $eaTileDir/LIDAR-DTM-2M-${tileName}/*.asc
gdalbuildvrt -resolution highest -a_srs EPSG:27700 -srcnodata "-9998" -vrtnodata "-9998" -hidenodata scratch/${tileName}_Mask.vrt $eaTileDir/LIDAR-DTM-2M-${tileName}/*.asc
gdal_calc.py -A scratch/${tileName}_Mask.vrt --outfile=scratch/${tileName}_Mask.tif --calc="255*(maximum(A<0, A==-9998))" --type=Byte --NoDataValue=0
gdal_polygonize.py -f "ESRI Shapefile" scratch/${tileName}_Mask.tif scratch/mask.shp
ogr2ogr -f "ESRI Shapefile" scratch/mask_larger.shp scratch/mask.shp -dialect sqlite -sql "SELECT ST_Union(ST_Buffer(Geometry, ${blendDistance})) from mask"

# GDAL <2.0 doesn't make the kernel larger for upscaling so this is a hacky workaround
gdalwarp -of HFA -r cubicspline -s_srs EPSG:27700 -ts 400 400 $osTileDir/${tileName}.asc scratch/${tileName}_Pass1.img
gdalwarp -of HFA -r cubicspline -s_srs EPSG:27700 -ts 800 800 scratch/${tileName}_Pass1.img scratch/${tileName}_Pass2.img
gdalwarp -of HFA -r cubicspline -s_srs EPSG:27700 -ts 1600 1600 scratch/${tileName}_Pass2.img scratch/${tileName}_Pass3.img
gdalwarp -s_srs EPSG:27700 -tr ${targetResolution} ${targetResolution} -r cubicspline -cutline scratch/mask_larger.shp -cblend ${blendCells} -dstalpha -crop_to_cutline scratch/${tileName}_Pass3.img scratch/${tileName}_Blend.tif

# HT: http://reprojected.com/blog/2012/09/12/extracting-extent-from-gdalinfo-on-the-command-line/
finalExtent=`gdalinfo $osTileDir/${tileName}.asc | awk '/(Lower Left)|(Upper Right)/' | awk '{gsub(/,|\)|\(/," ");print $3 " " $4}' | sed ':a;N;$!ba;s/\n/ /g'`
gdalwarp -of HFA -s_srs EPSG:27700 -tr ${targetResolution} ${targetResolution} -te $finalExtent scratch/${tileName}.vrt scratch/${tileName}_Blend.tif ${tileName}_Final.img

gdal_contour -a LEVEL -i 5 ${tileName}_Final.img ${tileName}_Contours.shp

mv ${tileName}_Contours.* $targetDir/contours/
mv ${tileName}_Final.img $targetDir/grid/${tileName}.img
mv scratch/mask.shp $targetDir/coverage/${tileName}.shp
mv scratch/mask.shx $targetDir/coverage/${tileName}.shx
mv scratch/mask.dbf $targetDir/coverage/${tileName}.dbf
mv scratch/mask.prj $targetDir/coverage/${tileName}.prj

rm -rf scratch > /dev/null 2> /dev/null
rm ${tileName}_Contours.* > /dev/null 2> /dev/null
rm ${tileName}_Final.* > /dev/null 2> /dev/null

cd $currentDir
