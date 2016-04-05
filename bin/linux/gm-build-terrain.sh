#!/bin/bash

tileName=`echo $1 | tr '[:lower:]' '[:upper:]'`
targetResolution="5"
blendDistance=50
blendCells=$(($blendDistance/(10000 / 1600) - 1))
binDir="/vagrant/bin/linux/"
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

finalExtent=`gdalinfo $osTileDir/${tileName}.asc | awk '/(Lower Left)|(Upper Right)/' | awk '{gsub(/,|\)|\(/," ");print $3 " " $4}' | sed ':a;N;$!ba;s/\n/ /g'`

# Check for archived LiDAR data
if [ -e "${eaTileDir}/LIDAR-DTM-2M-${tileName}.zip" ] || [ -e "${eaTileDir}/2m_res_${tileName}_dtm.zip" ]; then
	echo "Extracting ZIP file with EA/NRW LiDAR data..."
	unzip -o "${eaTileDir}/LIDAR-DTM-2M-${tileName}.zip" -d "${eaTileDir}/LIDAR-DTM-2M-${tileName}/"
	unzip -o "${eaTileDir}/2m_res_${tileName}_dtm.zip" -d "${eaTileDir}/LIDAR-DTM-2M-${tileName}/"
else
	# Check for pre-extracted LiDAR data
	if [ -d "${eaTileDir}/LIDAR-DTM-2M-${tileName}/" ]; then
		echo "LiDAR directory already exists."
	else
		# Try to download LiDAR data
		echo "No LiDAR directory found... attempting to download..."
		$binDir/gm-download-eagg.sh $tileName
		$binDir/gm-download-nrw.sh $tileName
		if [ -e "${eaTileDir}/LIDAR-DTM-2M-${tileName}.zip" ]; then
			echo "Extracting LiDAR..."
			unzip -o "${eaTileDir}/LIDAR-DTM-2M-${tileName}.zip" -d "${eaTileDir}/LIDAR-DTM-2M-${tileName}/"
		else
			echo "No LiDAR downloaded -- creating empty directory..."
			mkdir "${eaTileDir}/LIDAR-DTM-2M-${tileName}/"
		fi
	fi
fi

if [ `ls ${eaTileDir}/LIDAR-DTM-2M-${tileName}/*.asc | wc -l` -gt 0 ]; then
	gdalbuildvrt -resolution user -tr $targetResolution $targetResolution -a_srs EPSG:27700 scratch/${tileName}.vrt $eaTileDir/LIDAR-DTM-2M-${tileName}/*.asc
	gdalbuildvrt -resolution user -tr $targetResolution $targetResolution -a_srs EPSG:27700 -srcnodata "-9998" -vrtnodata "-9998" -hidenodata scratch/${tileName}_Mask.vrt $eaTileDir/LIDAR-DTM-2M-${tileName}/*.asc
	gdal_calc.py -A scratch/${tileName}_Mask.vrt --outfile=scratch/${tileName}_Mask.tif --calc="255*(maximum(A<0, A==-9998))" --type=Byte --NoDataValue=0
	gdal_polygonize.py -f "ESRI Shapefile" scratch/${tileName}_Mask.tif scratch/mask.shp

	# Two cases here: Gaps in LiDAR available, 100% LiDAR
	if [ `ogrinfo scratch/mask.shp | grep -c Polygon` -gt 0 ]; then
		echo "Gaps exist in LiDAR -- merging with OS Terrain 50"
		ogr2ogr -f "ESRI Shapefile" scratch/mask_larger.shp scratch/mask.shp -dialect sqlite -sql "SELECT ST_Union(ST_Buffer(Geometry, ${blendDistance})) from mask"
		# GDAL <2.0 doesn't make the kernel larger for upscaling so this is a hacky workaround
		gdalwarp -of HFA -r cubicspline -s_srs EPSG:27700 -ts 400 400 $osTileDir/${tileName}.asc scratch/${tileName}_Pass1.img
		gdalwarp -of HFA -r cubicspline -s_srs EPSG:27700 -ts 800 800 scratch/${tileName}_Pass1.img scratch/${tileName}_Pass2.img
		gdalwarp -of HFA -r cubicspline -s_srs EPSG:27700 -ts 1600 1600 scratch/${tileName}_Pass2.img scratch/${tileName}_Pass3.img
		gdalwarp -of HFA -r cubicspline -s_srs EPSG:27700 -ts 3200 3200 scratch/${tileName}_Pass3.img scratch/${tileName}_Pass4.img
		gdalwarp -of HFA -r cubicspline -s_srs EPSG:27700 -ts 5000 5000 scratch/${tileName}_Pass4.img scratch/${tileName}_Pass5.img
		gdalwarp -s_srs EPSG:27700 -tr ${targetResolution} ${targetResolution} -te $finalExtent -r cubicspline -cutline scratch/mask_larger.shp -cblend ${blendCells} -dstalpha -crop_to_cutline scratch/${tileName}_Pass5.img scratch/${tileName}_Blend.tif
		# HT: http://reprojected.com/blog/2012/09/12/extracting-extent-from-gdalinfo-on-the-command-line/
		gdalwarp -of HFA -s_srs EPSG:27700 -tr ${targetResolution} ${targetResolution} -te $finalExtent scratch/${tileName}_Pass5.img scratch/${tileName}.vrt scratch/${tileName}_Blend.tif ${tileName}_Final.img
	else
		echo "No gaps exist in the LiDAR coverage -- LiDAR only"
		gdalwarp -of HFA -s_srs EPSG:27700 -tr ${targetResolution} ${targetResolution} -te $finalExtent scratch/${tileName}.vrt ${tileName}_Final.img
	fi
else
	echo "No LiDAR data found -- trigger a download if required"
	gdalwarp -of HFA -r cubicspline -s_srs EPSG:27700 -ts 400 400 $osTileDir/${tileName}.asc scratch/${tileName}_Pass1.img
	gdalwarp -of HFA -r cubicspline -s_srs EPSG:27700 -ts 800 800 scratch/${tileName}_Pass1.img scratch/${tileName}_Pass2.img
	gdalwarp -of HFA -r cubicspline -s_srs EPSG:27700 -ts 1600 1600 scratch/${tileName}_Pass2.img scratch/${tileName}_Pass3.img
	gdalwarp -of HFA -r cubicspline -s_srs EPSG:27700 -ts 3200 3200 scratch/${tileName}_Pass3.img scratch/${tileName}_Pass4.img
	gdalwarp -of HFA -r cubicspline -s_srs EPSG:27700 -ts 5000 5000 scratch/${tileName}_Pass4.img scratch/${tileName}_Pass5.img
	gdalwarp -of HFA -s_srs EPSG:27700 -tr ${targetResolution} ${targetResolution} -te $finalExtent scratch/${tileName}_Pass5.img ${tileName}_Final.img
fi

gdal_contour -a LEVEL -i 5 ${tileName}_Final.img ${tileName}_Contours.shp

mv ${tileName}_Contours.* $targetDir/contours/
mv ${tileName}_Final.img $targetDir/grid/${tileName}.img
mv scratch/mask.shp $targetDir/coverage/${tileName}.shp
mv scratch/mask.shx $targetDir/coverage/${tileName}.shx
mv scratch/mask.dbf $targetDir/coverage/${tileName}.dbf
mv scratch/mask.prj $targetDir/coverage/${tileName}.prj

IFS=' ' read -r -a finalBounds <<< "$finalExtent"
deleteBox="ST_SetSRID(ST_MakeBox2D(ST_Point(${finalBounds[0]}, ${finalBounds[1]}), ST_Point(${finalBounds[2]}, ${finalBounds[3]})), 27700)"
psql -Ugrough-map grough-map -h 127.0.0.1 -c "DELETE FROM elevation WHERE elevation_geom && $deleteBox AND ST_Within(elevation_geom, $deleteBox)"
shp2pgsql -S -s 27700 -d -W LATIN1 -N skip "$targetDir/contours/${tileName}_Contours.shp" _src_contours >> scratch/_src_contours.sql 2> /dev/null
psql -Ugrough-map grough-map -h 127.0.0.1 -f scratch/_src_contours.sql > /dev/null
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO elevation (elevation_level, elevation_geom)
	SELECT 
		c.level, 
		(ST_Dump(
			ST_Simplify(
				CASE WHEN Count(s.surface_geom) > 0
					THEN ST_Difference(
						c.geom, 
						ST_MakeValid(ST_Buffer(ST_Collect(s.surface_geom), -50.0))
					)
					ELSE c.geom
				END, 
				2.5)
			)
		).geom
	FROM 
		_src_contours c
	LEFT JOIN
		surface s
	ON
		s.surface_geom && c.geom
	AND
		ST_Intersects(c.geom, s.surface_geom)
	AND
		s.surface_class_id IN (5, 6)
	GROUP BY
		c.level, c.geom;
EoSQL
psql -Ugrough-map grough-map -h 127.0.0.1 -c "DROP TABLE IF EXISTS _src_contours;"

rm -rf scratch > /dev/null 2> /dev/null
rm ${tileName}_Contours.* > /dev/null 2> /dev/null
rm ${tileName}_Final.* > /dev/null 2> /dev/null

if [ -e "${eaTileDir}/LIDAR-DTM-2M-${tileName}.zip" ] || [ -e "${eaTileDir}/2m_res_${tileName}_dtm.zip" ]; then
	echo "Removing ZIP file extracts..."
	rm -rf "${eaTileDir}/LIDAR-DTM-2M-${tileName}/"
fi

cd $currentDir
