#!/bin/bash

function downloadAndExtractTile {
	# Check for archived LiDAR data
	if [ -e "${eaTileDir}/LIDAR-DTM-2M-${1}.zip" ] || [ -e "${eaTileDir}/2m_res_${1}_dtm.zip" ]; then
		if [ ! -d "${scratchDir}/LIDAR-DTM-2M-${1}/" ] || [ ! -d "${scratchDir}/LIDAR-DSM-2M-${1}/" ]; then
			echo "--> Extracting ZIP file with EA/NRW LiDAR data..."
			unzip -o "${eaTileDir}/LIDAR-DTM-2M-${1}.zip" -d "${scratchDir}/LIDAR-DTM-2M-${1}/"
			unzip -o "${eaTileDir}/LIDAR-DSM-2M-${1}.zip" -d "${scratchDir}/LIDAR-DSM-2M-${1}/"
		else
			echo "--> Tile already extracted ($1)."
		fi
	else
		# Check for pre-extracted LiDAR data
		if [ -d "${eaTileDir}/LIDAR-DTM-2M-${1}/" ]; then
			echo "--> LiDAR directory already exists."
		else
			# Try to download LiDAR data
			echo "--> No LiDAR directory found... cannot continue."
			exit
		fi
	fi
}

tileName=`echo $1 | tr '[:lower:]' '[:upper:]'`
binDir="/vagrant/bin/linux/"
scratchDir="/tmp/"
sqlDir="/vagrant/source/sql/"
osTileDir="/vagrant/source/os-terrain/"
eaTileDir="/vagrant/source/eagg/"
targetDir="/vagrant/source/terrain-composite/"
currentDir=`pwd`
maxExtractsAllowed=25

threshold1Metres="0.05"
threshold1Label="5cm"
threshold2Metres="0.15"
threshold2Label="15cm"
threshold3Metres="0.40"
threshold3Label="40cm"

cd $scratchDir
mkdir obstructions

echo "--> Storing spatial extent..."
tileExtent=`gdalinfo obstructions/${tileName}_DTM.vrt | awk '/(Upper Left)|(Lower Right)/' | awk '{gsub(/,|\)|\(/," ");print $3 " " $4}' | sed ':a;N;$!ba;s/\n/ /g'`
echo $tileExtent

echo "--> Extracting tiles..."
downloadAndExtractTile $tileName

echo "--> Building VRTs..."
gdalbuildvrt -a_srs EPSG:27700 obstructions/${tileName}_DTM.vrt $scratchDir/LIDAR-DTM-2M-${tileName}/*.asc
gdalbuildvrt -a_srs EPSG:27700 obstructions/${tileName}_DEM.vrt $scratchDir/LIDAR-DSM-2M-${tileName}/*.asc

<<END

echo "--> Calculating superficial differences..."
echo "-->  > ${threshold1Label}"
gdal_calc.py -A obstructions/${tileName}_DEM.vrt -B obstructions/${tileName}_DTM.vrt --outfile obstructions/${tileName}_Superficial_${threshold1Label}.tif --format=GTiff --overwrite --calc="(((A-B)>0)*(A-B))>=${threshold1Metres}" --NoDataValue=0
echo "-->  > ${threshold2Label}"
gdal_calc.py -A obstructions/${tileName}_DEM.vrt -B obstructions/${tileName}_DTM.vrt --outfile obstructions/${tileName}_Superficial_${threshold2Label}.tif --format=GTiff --overwrite --calc="(((A-B)>0)*(A-B))>=${threshold2Metres}" --NoDataValue=0
echo "-->  > ${threshold3Label}"
gdal_calc.py -A obstructions/${tileName}_DEM.vrt -B obstructions/${tileName}_DTM.vrt --outfile obstructions/${tileName}_Superficial_${threshold3Label}.tif --format=GTiff --overwrite --calc="(((A-B)>0)*(A-B))>=${threshold3Metres}" --NoDataValue=0

echo "--> Compressing..."
convert "obstructions/${tileName}_Superficial_${threshold1Label}.tif" -compress lzw "obstructions/${tileName}_Superficial_${threshold1Label}.tif"
convert "obstructions/${tileName}_Superficial_${threshold2Label}.tif" -compress lzw "obstructions/${tileName}_Superficial_${threshold2Label}.tif"
convert "obstructions/${tileName}_Superficial_${threshold3Label}.tif" -compress lzw "obstructions/${tileName}_Superficial_${threshold3Label}.tif"

echo "--> Generating skeletons..."
echo "-->  > ${threshold1Label}"
"$binDir/CVTool/cvtool" "$scratchDir/obstructions/${tileName}_Superficial_${threshold1Label}.tif"
echo "-->  > ${threshold2Label}"
"$binDir/CVTool/cvtool" "$scratchDir/obstructions/${tileName}_Superficial_${threshold2Label}.tif"
echo "-->  > ${threshold3Label}"
"$binDir/CVTool/cvtool" "$scratchDir/obstructions/${tileName}_Superficial_${threshold3Label}.tif"

echo "--> Reassigning spatial reference data..."
gdal_translate -ot Byte -a_srs EPSG:27700 -a_ullr ${tileExtent} "$scratchDir/obstructions/${tileName}_Superficial_${threshold1Label}_Skel.tif" "$scratchDir/obstructions/${tileName}_Superficial_${threshold1Label}_Skel_Geo.tif"
gdal_translate -ot Byte -a_srs EPSG:27700 -a_ullr ${tileExtent} "$scratchDir/obstructions/${tileName}_Superficial_${threshold2Label}_Skel.tif" "$scratchDir/obstructions/${tileName}_Superficial_${threshold2Label}_Skel_Geo.tif"
gdal_translate -ot Byte -a_srs EPSG:27700 -a_ullr ${tileExtent} "$scratchDir/obstructions/${tileName}_Superficial_${threshold3Label}_Skel.tif" "$scratchDir/obstructions/${tileName}_Superficial_${threshold3Label}_Skel_Geo.tif"

# TODO: Convert to vector

# TODO: Import to database server

# TODO: Clean

# TODO: Add to linear features 

echo "--> Copying rasters..."
cp obstructions/${tileName}_Superficial_* /vagrant/volatile/

#rm -rf obstructions > /dev/null 2> /dev/null

# Remove extract directories, oldest first, when there exists more than an allowed amount
find $scratchDir -mindepth 1 -maxdepth 1 -not -empty -type d -printf "%T@ %p\n" | sort -n | cut -d ' ' -f2 | tail -n +${maxExtractsAllowed} | xargs rm -rf

echo "GISDBASE: ${scratchDir}/obstructions" > ${scratchDir}/grassrc
echo "LOCATION_NAME: linear" >> ${scratchDir}/grassrc
echo "MAPSET: PERMANENT" >> ${scratchDir}/grassrc
echo "GASS_GUI: text" >> ${scratchDir}/grassrc

export GISBASE=`grass70 --config path`
export GISRC="${scratchDir}/grassrc"
export GRASS_MESSAGE_FORMAT=plain
export LD_LIBRARY_PATH="${GISBASE}/lib"
export GRASS_LD_LIBRARY_PATH="${LD_LIBRARY_PATH}"
export PATH=${PATH}:${GISBASE}/bin:${GISBASE}/scripts


# Convert to vectors
rm -rf "${scratchDir}/obstructions/linear"
rm -rf ${scratchDir}/obstructions/*.shp
rm -rf ${scratchDir}/obstructions/*.dbf
rm -rf ${scratchDir}/obstructions/*.shx
rm -rf ${scratchDir}/obstructions/*.prj

g.proj -c epsg=27700 location=linear
g.region -s 

echo "--> Importing rasters..."
r.in.gdal -e input="$scratchDir/obstructions/${tileName}_Superficial_${threshold1Label}_Skel_Geo.tif" output=Linear${threshold1Label} --overwrite
r.in.gdal -e input="$scratchDir/obstructions/${tileName}_Superficial_${threshold2Label}_Skel_Geo.tif" output=Linear${threshold2Label} --overwrite
r.in.gdal -e input="$scratchDir/obstructions/${tileName}_Superficial_${threshold3Label}_Skel_Geo.tif" output=Linear${threshold3Label} --overwrite

echo "--> Setting region extent..."
IFS=' ' read -r -a tileBounds <<< "${tileExtent}"
g.region n=${tileBounds[1]} e=${tileBounds[2]} s=${tileBounds[3]} w=${tileBounds[0]}
g.region -p

echo "--> Setting no data value..."
r.mapcalc "Linear${threshold1Label} = if(Linear${threshold1Label}<=0, null(), 255)" --overwrite
r.mapcalc "Linear${threshold2Label} = if(Linear${threshold2Label}<=0, null(), 255)" --overwrite
r.mapcalc "Linear${threshold3Label} = if(Linear${threshold3Label}<=0, null(), 255)" --overwrite

echo "--> Thinning rasters..."
r.thin input="Linear${threshold1Label}" output="LinearThin${threshold1Label}" --overwrite --verbose
r.thin input="Linear${threshold2Label}" output="LinearThin${threshold2Label}" --overwrite --verbose
r.thin input="Linear${threshold3Label}" output="LinearThin${threshold3Label}" --overwrite --verbose

echo "--> Converting to vectors..."
r.to.vect input=LinearThin${threshold1Label} output=${tileName}_Lines_${threshold1Label} type=line --overwrite --verbose
r.to.vect input=LinearThin${threshold2Label} output=${tileName}_Lines_${threshold2Label} type=line --overwrite --verbose
r.to.vect input=LinearThin${threshold3Label} output=${tileName}_Lines_${threshold3Label} type=line --overwrite --verbose

echo "--> Cleaning vectors..."
v.clean input=${tileName}_Lines_${threshold1Label} output=${tileName}_Lines_Clean_${threshold1Label} tool=rmdangle,prune threshold=1.0,5.0 --overwrite
v.clean input=${tileName}_Lines_${threshold2Label} output=${tileName}_Lines_Clean_${threshold2Label} tool=rmdangle,prune threshold=1.0,5.0 --overwrite
v.clean input=${tileName}_Lines_${threshold3Label} output=${tileName}_Lines_Clean_${threshold3Label} tool=rmdangle,prune threshold=1.0,5.0 --overwrite

echo "--> Outputting vectors..."
v.out.ogr input=${tileName}_Lines_Clean_${threshold1Label} type=line format=ESRI_Shapefile output="$scratchDir/obstructions/"
v.out.ogr input=${tileName}_Lines_Clean_${threshold2Label} type=line format=ESRI_Shapefile output="$scratchDir/obstructions/"
v.out.ogr input=${tileName}_Lines_Clean_${threshold3Label} type=line format=ESRI_Shapefile output="$scratchDir/obstructions/"

echo "--> Copying shapefiles..."
cp obstructions/${tileName}_Lines_* /vagrant/volatile/
END

echo "--> Converting to SQL..."
shp2pgsql -s 27700 -d -W LATIN1 -N skip obstructions/${tileName}_Lines_Clean_${threshold1Label}.shp _src_obstructions_lev1 > _src_obstructions_lev1.sql 2> /dev/null
shp2pgsql -s 27700 -d -W LATIN1 -N skip obstructions/${tileName}_Lines_Clean_${threshold2Label}.shp _src_obstructions_lev2 > _src_obstructions_lev2.sql 2> /dev/null
shp2pgsql -s 27700 -d -W LATIN1 -N skip obstructions/${tileName}_Lines_Clean_${threshold3Label}.shp _src_obstructions_lev3 > _src_obstructions_lev3.sql 2> /dev/null

echo "--> Importing SQL..."
psql -Ugrough-map grough-map -h 127.0.0.1 -f _src_obstructions_lev1.sql > /dev/null
psql -Ugrough-map grough-map -h 127.0.0.1 -f _src_obstructions_lev2.sql > /dev/null
psql -Ugrough-map grough-map -h 127.0.0.1 -f _src_obstructions_lev3.sql > /dev/null

echo "--> Identifying surfaces..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	DROP TABLE IF EXISTS _tmp_surface;

	CREATE TABLE
		_tmp_surface
	AS SELECT
		ST_MakeValid(surface_geom) AS geom
	FROM
		surface 
	WHERE
		surface_class_id IN (2, 3, 5, 6, 8, 20)
	AND
		surface_geom && (
			SELECT
				ST_MakeBox2D(
					ST_Point(ST_XMin(geom), ST_YMin(geom)),
					ST_Point(ST_XMax(geom), ST_YMax(geom))
				)
			FROM
				(SELECT ST_Collect(geom) AS geom FROM _src_obstructions_lev1 GROUP BY true) a
		);
EoSQL

for level in 1 2 3;
do
	echo "--> Ensuring no multigeometries exist..."
	psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
		ALTER TABLE _src_obstructions_lev${level} 
			ALTER COLUMN geom 
			TYPE geometry(LineString, 27700) 
			USING ST_Simplify(ST_GeometryN(geom, 1), 2);
EoSQL
	
	echo "--> Adding index and clustering ($level)..."
	psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
		DROP INDEX IF EXISTS "_src_obstructions_lev${level}::geom";
		CREATE INDEX "_src_obstructions_lev${level}::geom"
			ON public._src_obstructions_lev${level}
			USING gist
			(geom);
		ALTER TABLE public._src_obstructions_lev${level} CLUSTER ON "_src_obstructions_lev${level}::geom";
EoSQL

	echo "--> Deleting within water and forest etc ($level)..."	
	psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
		DELETE FROM
			_src_obstructions_lev${level}
		WHERE 
			gid 
		IN
		(
			SELECT
				gid
			FROM
				_src_obstructions_lev${level} o, _tmp_surface s
			WHERE
				o.geom && s.geom
			AND
				ST_Within(o.geom, s.geom)
		);
EoSQL
done

echo "--> Removing temporary tables..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	DROP TABLE IF EXISTS _tmp_surface;
EoSQL

# Build obstructions 
psql -Ugrough-map grough-map -h 127.0.0.1 -f "$sqlDir/walls_clean_and_build.sql" > /dev/null

# Remove stubs

# Join nearby


cd $currentDir
