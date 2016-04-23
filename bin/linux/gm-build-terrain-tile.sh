#!/bin/bash

function getTileExtent {
	local tileExtent=`gdalinfo $osTileDir/$1.asc | awk '/(Lower Left)|(Upper Right)/' | awk '{gsub(/,|\)|\(/," ");print $3 " " $4}' | sed ':a;N;$!ba;s/\n/ /g'`
	echo $tileExtent
}

function getEnlargedExtent {
	IFS=' ' read -r -a tileBounds <<< "$(getTileExtent $1)"
	
	tileCentreE=$(( (${tileBounds[0]%.*} + ${tileBounds[2]%.*}) / 2 ))
	tileCentreN=$(( (${tileBounds[1]%.*} + ${tileBounds[3]%.*}) / 2 ))
	
	edgeLeft=$(( $tileCentreE - 6000 ))
	edgeRight=$(( $tileCentreE + 6000 ))
	edgeUp=$(( $tileCentreN + 6000 ))
	edgeDown=$(( $tileCentreN - 6000 ))
	
	echo $edgeLeft $edgeDown $edgeRight $edgeUp
}

function getNeighbouringTiles {
	IFS=' ' read -r -a tileBounds <<< "$(getEnlargedExtent $1)"
	
	tileCentreE=$(( (${tileBounds[0]%.*} + ${tileBounds[2]%.*}) / 2 ))
	tileCentreN=$(( (${tileBounds[1]%.*} + ${tileBounds[3]%.*}) / 2 ))
	
	# To the left
	tileLeft=`"${binDir}/grid/bng.py" -e $(( $tileCentreE - 5050 )) -n $tileCentreN`
	tileRight=`"${binDir}/grid/bng.py" -e $(( $tileCentreE + 5050 )) -n $tileCentreN`
	tileUp=`"${binDir}/grid/bng.py" -e $tileCentreE -n $(( $tileCentreN + 5050 ))`
	tileDown=`"${binDir}/grid/bng.py" -e $tileCentreE -n $(( $tileCentreN - 5050 ))`
	
	tileTL=`"${binDir}/grid/bng.py" -e $(( $tileCentreE - 5050 )) -n $(( $tileCentreN + 5050 ))`
	tileTR=`"${binDir}/grid/bng.py" -e $(( $tileCentreE + 5050 )) -n $(( $tileCentreN + 5050 ))`
	tileBL=`"${binDir}/grid/bng.py" -e $(( $tileCentreE - 5050 )) -n $(( $tileCentreN - 5050 ))`
	tileBR=`"${binDir}/grid/bng.py" -e $(( $tileCentreE + 5050 )) -n $(( $tileCentreN - 5050 ))`
	
	echo $tileLeft $tileRight $tileUp $tileDown $tileTL $tileTR $tileBL $tileBR
}

function downloadAndExtractTile {
	# Check for archived LiDAR data
	if [ -e "${eaTileDir}/LIDAR-DTM-2M-${1}.zip" ] || [ -e "${eaTileDir}/2m_res_${1}_dtm.zip" ]; then
		if [ ! -d "${scratchDir}/LIDAR-DTM-2M-${1}/" ]; then
			echo "Extracting ZIP file with EA/NRW LiDAR data..."
			unzip -o "${eaTileDir}/LIDAR-DTM-2M-${1}.zip" -d "${scratchDir}/LIDAR-DTM-2M-${1}/"
			unzip -o "${eaTileDir}/2m_res_${1}_dtm.zip" -d "${scratchDir}/LIDAR-DTM-2M-${1}/"
		else
			echo "Tile already extracted ($1)."
		fi
	else
		# Check for pre-extracted LiDAR data
		if [ -d "${eaTileDir}/LIDAR-DTM-2M-${1}/" ]; then
			echo "LiDAR directory already exists."
		else
			# Try to download LiDAR data
			echo "No LiDAR directory found... attempting to download..."
			$binDir/gm-download-eagg.sh $1
			$binDir/gm-download-nrw.sh $1
			if [ -e "${eaTileDir}/LIDAR-DTM-2M-${1}.zip" ] || [ -e "${eaTileDir}/2m_res_${1}_dtm.zip" ]; then
				echo "Extracting LiDAR..."
				unzip -o "${eaTileDir}/LIDAR-DTM-2M-${1}.zip" -d "${scratchDir}/LIDAR-DTM-2M-${1}/"
				unzip -o "${eaTileDir}/2m_res_${1}_dtm.zip" -d "${scratchDir}/LIDAR-DTM-2M-${1}/"
			else
				echo "No LiDAR downloaded -- creating empty directory..."
				mkdir "${eaTileDir}/LIDAR-DTM-2M-${1}/"
			fi
		fi
	fi
}

function prepareRequiredTiles {
	IFS=' ' read -r -a tileNames <<< "$(getNeighbouringTiles $1)"
	
	downloadAndExtractTile $1
	downloadAndExtractTile ${tileNames[0]}
	downloadAndExtractTile ${tileNames[1]}
	downloadAndExtractTile ${tileNames[2]}
	downloadAndExtractTile ${tileNames[3]}
	downloadAndExtractTile ${tileNames[4]}
	downloadAndExtractTile ${tileNames[5]}
	downloadAndExtractTile ${tileNames[6]}
	downloadAndExtractTile ${tileNames[7]}
}

tileName=`echo $1 | tr '[:lower:]' '[:upper:]'`
targetResolution="5"
blendDistance=50
blendCells=$(($blendDistance/(10000 / 1600) - 1))
binDir="/vagrant/bin/linux/"
scratchDir="/tmp/"
osTileDir="/vagrant/source/os-terrain/"
eaTileDir="/vagrant/source/eagg/"
targetDir="/vagrant/source/terrain-composite/"
currentDir=`pwd`
maxExtractsAllowed=25

mkdir $targetDir/grid > /dev/null 2> /dev/null

cd $scratchDir
rm -rf scratch > /dev/null 2> /dev/null
rm ${tileName}_Contours.*  > /dev/null 2> /dev/null
rm ${tileName}_Final.* > /dev/null 2> /dev/null
mkdir scratch

if [ -z "$tileName" ]; then
	echo "Must supply tile name, e.g. NZ26"
	exit 1
else
	echo "Using tile name $tileName"
fi

if [ ! -e "$osTileDir/${tileName}.asc" ]; then
	echo "Must supply a valid tile name, e.g. NZ26. No base data for $tileName."
	exit 1
else
	echo "Identified base data from OS Terrain 50 for the tile."
fi

finalExtent=$(getTileExtent ${tileName})
processingExtent=$(getEnlargedExtent ${tileName})
IFS=' ' read -r -a neighbourTiles <<< "$(getNeighbouringTiles $1)"
prepareRequiredTiles $tileName
echo Neighbouring tiles are ${neighbourTiles[0]} ${neighbourTiles[1]} ${neighbourTiles[2]} ${neighbourTiles[3]}
echo Corner tiles are ${neighbourTiles[4]} ${neighbourTiles[5]} ${neighbourTiles[6]} ${neighbourTiles[7]}
echo Processing extent is $processingExtent
echo Final extent is $finalExtent

if [ `ls ${scratchDir}/LIDAR-DTM-2M-${tileName}/*.asc | wc -l` -gt 0 ]; then
	echo "--> Building VRT for LiDAR"
	gdalbuildvrt -te $processingExtent -resolution user -tr $targetResolution $targetResolution -a_srs EPSG:27700 scratch/${tileName}.vrt $scratchDir/LIDAR-DTM-2M-${tileName}/*.asc $scratchDir/LIDAR-DTM-2M-${neighbourTiles[0]}/*.asc $scratchDir/LIDAR-DTM-2M-${neighbourTiles[1]}/*.asc $scratchDir/LIDAR-DTM-2M-${neighbourTiles[2]}/*.asc $scratchDir/LIDAR-DTM-2M-${neighbourTiles[3]}/*.asc  $scratchDir/LIDAR-DTM-2M-${neighbourTiles[4]}/*.asc $scratchDir/LIDAR-DTM-2M-${neighbourTiles[5]}/*.asc $scratchDir/LIDAR-DTM-2M-${neighbourTiles[6]}/*.asc $scratchDir/LIDAR-DTM-2M-${neighbourTiles[7]}/*.asc
	gdalbuildvrt -te $processingExtent -resolution user -tr $targetResolution $targetResolution -a_srs EPSG:27700 -srcnodata "-9998" -vrtnodata "-9998" -hidenodata scratch/${tileName}_Mask.vrt $scratchDir/LIDAR-DTM-2M-${tileName}/*.asc $scratchDir/LIDAR-DTM-2M-${neighbourTiles[0]}/*.asc $scratchDir/LIDAR-DTM-2M-${neighbourTiles[1]}/*.asc $scratchDir/LIDAR-DTM-2M-${neighbourTiles[2]}/*.asc $scratchDir/LIDAR-DTM-2M-${neighbourTiles[3]}/*.asc  $scratchDir/LIDAR-DTM-2M-${neighbourTiles[4]}/*.asc $scratchDir/LIDAR-DTM-2M-${neighbourTiles[5]}/*.asc $scratchDir/LIDAR-DTM-2M-${neighbourTiles[6]}/*.asc $scratchDir/LIDAR-DTM-2M-${neighbourTiles[7]}/*.asc
	echo "--> Converting extent to polygon"
	gdal_calc.py -A scratch/${tileName}_Mask.vrt --outfile=scratch/${tileName}_Mask.tif --calc="255*(maximum(A<0, A==-9998))" --type=Byte --NoDataValue=0
	gdal_polygonize.py -f "ESRI Shapefile" scratch/${tileName}_Mask.tif scratch/mask.shp

	# Two cases here: Gaps in LiDAR available, 100% LiDAR
	if [ `ogrinfo scratch/mask.shp | grep -c Polygon` -gt 0 ]; then
		echo "Gaps exist in LiDAR -- merging with OS Terrain 50"
		ogr2ogr -f "ESRI Shapefile" scratch/mask_larger.shp scratch/mask.shp -dialect sqlite -sql "SELECT ST_Union(ST_Buffer(Geometry, ${blendDistance})) from mask"
		# GDAL <2.0 doesn't make the kernel larger for upscaling so this is a hacky workaround
		echo "--> Building VRT for OS Terrain 50"
		gdalbuildvrt -te $processingExtent -resolution user -tr 50 50 -a_srs EPSG:27700 scratch/OS_${tileName}.vrt $osTileDir/${tileName}.asc $osTileDir/${neighbourTiles[0]}.asc $osTileDir/${neighbourTiles[1]}.asc $osTileDir/${neighbourTiles[2]}.asc $osTileDir/${neighbourTiles[3]}.asc $osTileDir/${neighbourTiles[4]}.asc $osTileDir/${neighbourTiles[5]}.asc $osTileDir/${neighbourTiles[6]}.asc $osTileDir/${neighbourTiles[7]}.asc
		echo "--> Resampling OS data"
		gdalwarp -of HFA -r cubicspline -s_srs EPSG:27700 -ts 400 400 scratch/OS_${tileName}.vrt scratch/${tileName}_Pass1.img
		gdalwarp -of HFA -r cubicspline -s_srs EPSG:27700 -ts 800 800 scratch/${tileName}_Pass1.img scratch/${tileName}_Pass2.img
		gdalwarp -of HFA -r cubicspline -s_srs EPSG:27700 -ts 1600 1600 scratch/${tileName}_Pass2.img scratch/${tileName}_Pass3.img
		gdalwarp -of HFA -r cubicspline -s_srs EPSG:27700 -ts 3200 3200 scratch/${tileName}_Pass3.img scratch/${tileName}_Pass4.img
		gdalwarp -of HFA -r cubicspline -s_srs EPSG:27700 -ts 5000 5000 scratch/${tileName}_Pass4.img scratch/${tileName}_Pass5.img
		gdalwarp -s_srs EPSG:27700 -tr ${targetResolution} ${targetResolution} -te $processingExtent -r cubicspline -cutline scratch/mask_larger.shp -cblend ${blendCells} -dstalpha -crop_to_cutline scratch/${tileName}_Pass5.img scratch/${tileName}_Blend.tif
		# HT: http://reprojected.com/blog/2012/09/12/extracting-extent-from-gdalinfo-on-the-command-line/
		gdalwarp -of HFA -s_srs EPSG:27700 -tr ${targetResolution} ${targetResolution} -te $processingExtent scratch/${tileName}_Pass5.img scratch/${tileName}.vrt scratch/${tileName}_Blend.tif ${tileName}_Final.img
	else
		echo "No gaps exist in the LiDAR coverage -- LiDAR only"
		gdalwarp -of HFA -s_srs EPSG:27700 -tr ${targetResolution} ${targetResolution} -te $processingExtent scratch/${tileName}.vrt ${tileName}_Final.img
	fi
else
	echo "No LiDAR data found -- trigger a download if required"
	echo "--> Building VRT for OS Terrain 50"
	gdalbuildvrt -te $processingExtent -resolution user -tr 50 50 -a_srs EPSG:27700 scratch/OS_${tileName}.vrt $osTileDir/${tileName}.asc $osTileDir/${neighbourTiles[0]}.asc $osTileDir/${neighbourTiles[1]}.asc $osTileDir/${neighbourTiles[2]}.asc $osTileDir/${neighbourTiles[3]}.asc $osTileDir/${neighbourTiles[4]}.asc $osTileDir/${neighbourTiles[5]}.asc $osTileDir/${neighbourTiles[6]}.asc $osTileDir/${neighbourTiles[7]}.asc
	echo "--> Resampling OS data"
	gdalwarp -of HFA -r cubicspline -s_srs EPSG:27700 -ts 400 400 scratch/OS_${tileName}.vrt scratch/${tileName}_Pass1.img
	gdalwarp -of HFA -r cubicspline -s_srs EPSG:27700 -ts 800 800 scratch/${tileName}_Pass1.img scratch/${tileName}_Pass2.img
	gdalwarp -of HFA -r cubicspline -s_srs EPSG:27700 -ts 1600 1600 scratch/${tileName}_Pass2.img scratch/${tileName}_Pass3.img
	gdalwarp -of HFA -r cubicspline -s_srs EPSG:27700 -ts 3200 3200 scratch/${tileName}_Pass3.img scratch/${tileName}_Pass4.img
	gdalwarp -of HFA -r cubicspline -s_srs EPSG:27700 -ts 5000 5000 scratch/${tileName}_Pass4.img scratch/${tileName}_Pass5.img
	gdalwarp -of HFA -s_srs EPSG:27700 -tr ${targetResolution} ${targetResolution} -te $processingExtent scratch/${tileName}_Pass5.img ${tileName}_Final.img
fi

echo "--> Creating contours"
gdal_contour -a LEVEL -i 5 ${tileName}_Final.img scratch/contours.shp

echo "--> Clipping contours"
rm -rf ${tileName}_Contours.shp
ogr2ogr -f "ESRI Shapefile" -skipfailures -nlt LINESTRING -clipsrc $finalExtent ${tileName}_Contours.shp scratch/contours.shp 

echo "--> Clipping coverage"
rm -rf ${tileName}_Coverage.shp
ogr2ogr -f "ESRI Shapefile" -skipfailures -explodecollections -nlt POLYGON -clipsrc $finalExtent ${tileName}_Coverage.shp scratch/mask.shp 

echo "--> Clipping raster"
rm -rf $targetDir/grid/${tileName}.img
gdalwarp -of HFA -t_srs EPSG:27700 -te $finalExtent ${tileName}_Final.img $targetDir/grid/${tileName}.img

IFS=' ' read -r -a finalBounds <<< "$finalExtent"
deleteBox="ST_SetSRID(ST_MakeBox2D(ST_Point(${finalBounds[0]}, ${finalBounds[1]}), ST_Point(${finalBounds[2]}, ${finalBounds[3]})), 27700)"

echo "--> Removing old data"
psql -Ugrough-map grough-map -h 127.0.0.1 -c "DELETE FROM elevation WHERE elevation_geom && $deleteBox AND ST_Within(elevation_geom, $deleteBox)"
psql -Ugrough-map grough-map -h 127.0.0.1 -c "DELETE FROM elevation_source WHERE source_geom && $deleteBox AND ST_Within(source_geom, $deleteBox)"

echo "--> Converting to SQL"
shp2pgsql -s 27700 -d -W LATIN1 -N skip "${tileName}_Contours.shp" _src_contours >> scratch/_src_contours.sql
shp2pgsql -s 27700 -d -W LATIN1 -N skip "${tileName}_Coverage.shp" _src_coverage >> scratch/_src_coverage.sql

echo "--> Importing SQL"
psql -Ugrough-map grough-map -h 127.0.0.1 -f scratch/_src_contours.sql > /dev/null
psql -Ugrough-map grough-map -h 127.0.0.1 -f scratch/_src_coverage.sql > /dev/null

echo "--> Adding to the main data table"
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO elevation (elevation_level, elevation_geom)
	SELECT 
		c.level, 
		(ST_Dump( ST_Simplify(c.geom, 2.5) )).geom
	FROM 
		_src_contours c;
EoSQL
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
BEGIN;
	CREATE TABLE IF NOT EXISTS _src_coverage (id integer, geom geometry);
COMMIT;
BEGIN;
	INSERT INTO elevation_source (source_geom, source_lidar)
	SELECT 
		CASE WHEN Count(c.geom) > 0
			THEN ST_Multi(ST_CollectionExtract(ST_Collect(ST_Simplify(c.geom, 2.5)), 3))
			ELSE ST_Multi(A.box)
		END,
		false
	FROM
		(SELECT $deleteBox AS box) A
	LEFT JOIN
		_src_coverage c
	ON
		true
	GROUP BY
		A.box;
COMMIT;
EoSQL
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
BEGIN;
	INSERT INTO elevation_source (source_geom, source_lidar)
	SELECT
		ST_Multi(
			ST_Difference(
				A.box,
				ST_Collect(ST_Simplify(c.geom, 2.5))
			)
		),
		true
	FROM
		(SELECT $deleteBox AS box) A
	INNER JOIN
		_src_coverage c
	ON
		true
	GROUP BY
		A.box;
COMMIT;
EoSQL

echo "--> Removing temporary tables"
psql -Ugrough-map grough-map -h 127.0.0.1 -c "DROP TABLE IF EXISTS _src_contours;"
psql -Ugrough-map grough-map -h 127.0.0.1 -c "DROP TABLE IF EXISTS _src_coverage;"

rm -rf scratch > /dev/null 2> /dev/null
rm ${tileName}_Contours.* > /dev/null 2> /dev/null
rm ${tileName}_Coverage.* > /dev/null 2> /dev/null
rm ${tileName}_Final.* > /dev/null 2> /dev/null

# Remove extract directories, oldest first, when there exists more than an allowed amount
find $scratchDir -mindepth 1 -maxdepth 1 -not -empty -type d -printf "%T@ %p\n" | sort -n | cut -d ' ' -f2 | tail -n +${maxExtractsAllowed} | xargs rm -rf

cd $currentDir
