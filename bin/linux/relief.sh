#!/bin/bash

tileName=`echo $1 | tr '[:lower:]' '[:upper:]'`
binDir="/vagrant/bin/linux/"
scratchDir="/tmp/"
sqlDir="/vagrant/source/sql/"
osTileDir="/vagrant/source/os-terrain/"
eaTileDir="/vagrant/source/eagg/"
targetDir="/vagrant/source/terrain-composite/"
currentDir=`pwd`
workingDir="contours"

rm -rf "${scratchDir}/${workingDir}"
cd $scratchDir
mkdir $workingDir

echo "--> Storing spatial extent..."
tileExtent=`gdalinfo $osTileDir/${tileName}.asc | awk '/(Lower Left)|(Upper Right)/' | awk '{gsub(/,|\)|\(/," ");print $3 " " $4}' | sed ':a;N;$!ba;s/\n/ /g'`
echo $tileExtent

echo "GISDBASE: ${scratchDir}/$workingDir" > ${scratchDir}/grassrc
echo "LOCATION_NAME: surface" >> ${scratchDir}/grassrc
echo "MAPSET: PERMANENT" >> ${scratchDir}/grassrc
echo "GASS_GUI: text" >> ${scratchDir}/grassrc

export GISBASE=`grass70 --config path`
export GISRC="${scratchDir}/grassrc"
export GRASS_MESSAGE_FORMAT=plain
export LD_LIBRARY_PATH="${GISBASE}/lib"
export GRASS_LD_LIBRARY_PATH="${LD_LIBRARY_PATH}"
export PATH=${PATH}:${GISBASE}/bin:${GISBASE}/scripts

g.proj -c epsg=27700 location=surface
g.region -s 

echo "--> Setting processing region..."
IFS=' ' read -r -a tileBounds <<< "${tileExtent}"
tileCentreE=$(( (${tileBounds[0]%.*} + ${tileBounds[2]%.*}) / 2 ))
tileCentreN=$(( (${tileBounds[1]%.*} + ${tileBounds[3]%.*}) / 2 ))

edgeLeft=$(( $tileCentreE - 6000 ))
edgeRight=$(( $tileCentreE + 6000 ))
edgeUp=$(( $tileCentreN + 6000 ))
edgeDown=$(( $tileCentreN - 6000 ))

cellRes=10
cellsX=$(( ($edgeRight - $edgeLeft)/$cellRes ))
cellsY=$(( ($edgeRight - $edgeLeft)/$cellRes ))

g.region n=$edgeUp s=$edgeDown w=$edgeLeft e=$edgeRight res=$cellRes -ap

echo "--> Extracting contours from database..."
pgsql2shp -f "${scratchDir}/${workingDir}/contours.shp" -u grough-map -h 127.0.0.1 grough-map \
	"SELECT elevation_level AS lev, elevation_geom FROM elevation WHERE elevation_geom && ST_MakeBox2D(ST_Point($edgeLeft, $edgeDown),ST_Point($edgeRight, $edgeUp))"

echo "--> Importing to GRASS..."
v.in.ogr input="${scratchDir}/${workingDir}/contours.shp" output="elev_contours" -r

echo "--> Converting to raster..."
v.to.rast input=elev_contours output=contour_raster use=attr attribute_column=LEV

echo "--> Creating surface..."
r.surf.contour in=contour_raster output=elev_raster

echo "--> Exporting from GRASS..."
r.out.gdal input=elev_raster output="${scratchDir}/${workingDir}/elev_${tileName}.img" format=HFA type=Float32 -f --overwrite --verbose

echo "--> Converting to relief..."
gdaldem hillshade -compute_edges -alt 30 "${scratchDir}/${workingDir}/elev_${tileName}.img" "${scratchDir}/${workingDir}/aspect_${tileName}.tif"
gdaldem color-relief "${scratchDir}/${workingDir}/elev_${tileName}.img" "$binDir/Mapnik/grough_relief.txt" "${scratchDir}/${workingDir}/relief_${tileName}.tif"
convert "${scratchDir}/${workingDir}/aspect_${tileName}.tif" -recolor "0.5 0.5 0.5, 0.5 0.5 0.5, 0.0 0.0 0.0" -gaussian-blur 5 -resize ${cellsX}x${cellsY}  "${scratchDir}/${workingDir}/aspect_colour_${tileName}.tif"
convert -size ${cellsX}x${cellsY} xc:white -colorspace RGB -alpha set -depth 8 -type TrueColor -compose over \( "${scratchDir}/${workingDir}/relief_${tileName}.tif" -alpha set -channel A -evaluate set 20% \) -composite "${scratchDir}/${workingDir}/relief_alpha_${tileName}.tif"
convert "${scratchDir}/${workingDir}/relief_alpha_${tileName}.tif" -colorspace RGB -alpha set -depth 8 -type TrueColor -compose Overlay \( "${scratchDir}/${workingDir}/aspect_colour_${tileName}.tif" -alpha set -channel A -evaluate set 80% \) -composite "${scratchDir}/${workingDir}/aspect_relief_${tileName}.tif"
convert -size ${cellsX}x${cellsY} xc:white \( "${scratchDir}/${workingDir}/aspect_relief_${tileName}.tif" -alpha set -channel A -evaluate set 50% \) -composite -depth 8 -layers flatten "${scratchDir}/${workingDir}/final_relief_${tileName}.tif"
gdal_translate -ot Byte -a_srs EPSG:27700 -a_ullr $edgeLeft $edgeUp $edgeRight $edgeDown "${scratchDir}/${workingDir}/final_relief_${tileName}.tif" "${scratchDir}/${workingDir}/geo_final_relief_${tileName}.tif"

echo "--> Copying files..."
cp "${scratchDir}/${workingDir}/"*.tif /vagrant/volatile/ # For testing only
cp "${scratchDir}/${workingDir}/geo_final_relief_${tileName}.tif" "${binDir}/Mapnik/relief/ReliefGeo.tif"

echo "--> Cleaning files..."
rm -rf "${scratchDir}/${workingDir}"

cd $currentDir
