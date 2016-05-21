#!/bin/bash

echo "Preparing to import Public Rights of Way products..."

fileBaseDir=/vagrant/source/prow/
binDir=../../bin/linux
sqlDir=/vagrant/source/sql/

for s in $binDir/gm-import-prow*
do
	dos2unix $s
done

if [ -z $1 ]
then
	searchTerm="*/"
else
	searchTerm=$1
fi

echo "Preparing aggregate database table..."
psql -A -t -Ugrough-map grough-map -h 127.0.0.1 -c "CREATE TABLE IF NOT EXISTS raw_prow \
( \
   id bigserial,  \
   geom geometry, \
   type character varying(30),  \
   source character varying(100),  \
   CONSTRAINT \"PKEY: raw_prow::id\" PRIMARY KEY (id) \
);"

echo "-----------------------------------"
echo "--> Extracting archives..."
echo "-----------------------------------"
cd $fileBaseDir
for d in $searchTerm
do
	areaName=`echo ${d%/} | sed 's/-/_/g'`
	echo "Found area $areaName..."

	if [ ! -e "$fileBaseDir/$d" ]; then
		echo "[ERROR] Does not exist: "$d
		exit 1
	fi
	
	echo " --> Clearing pre-existing data for this authority..."
	psql -A -t -Ugrough-map grough-map -h 127.0.0.1 -c "DELETE FROM raw_prow WHERE source LIKE '_src_prow_"$areaName"%'"
	
	echo " --> Attempting import..."
	cd "$fileBaseDir/$d"
	
	echo " --> Proceeding to extract archives..."
	for z in *.{zip,kmz}; do
		echo "     --> Extracting $z..."
		unzip -o "$z" > /dev/null 2> /dev/null

		echo " --> Attempting conversion routines..."
		
		IFS=$'\n'; for f in $(find ./ -iname '*.tab' -or -iname '*.kml' -or -iname '*.mif' -or -iname '*.geojson' | sed "s/^\.\///")
		do 
			targetCount=$(ls *.kmz | wc -l)
			if [ $targetCount -gt 0 ]; then
				targetName=`basename $z | sed -e 's/\..*$//g' -e 's/ [A-Z][a-z]/_\l&/g' -e 's/[- ]/_/g' -e 's/[^A-Za-z0-9_]//g' -e 's/[0-9_]\([0-9_]\+\)//g' -e 's/^_//g' -e 's/_$//g' -e 's/\(_\+\)/_/g' -e 's/byway_open_to_all_traffic/boat/g' -e 's/_prow_/_/g' -e 's/_row_/_/g' | tr '[:upper:]' '[:lower:]'`".shp"
			else
				targetName=${f%.*}.shp
			fi
			echo "     --> Found $f to be converted to $targetName..." 
			if [ $(find ./ -iname '*.dat' | wc -l) -eq 1 ]; then
				IFS=$'\n'; for r in $(find ./ -iname '*.dat' -or -iname '*.id' -or -iname '*.ind' -or -iname '*.map' -or -iname '*.tab' | sed "s/^\.\///"); do
					echo "     --> Renaming '"$r"' to '"${f%.*}.${r##*.}"'" 
					mv "$r" "${f%.*}.${r##*.}" > /dev/null 2> /dev/null
				done
			fi
			
			ogr2ogr -skipfailures -f "ESRI Shapefile" -t_srs "EPSG:27700" -overwrite "$targetName" "$f" #> /dev/null 2> /dev/null
		done
	done
	
	shapeCount=`find ./ -iname '*.shp' | wc -l`
	
	if [ $shapeCount -eq 0 ]; then
		echo "     --> [WARNING] No shapefiles found to be imported" 
	elif [ $shapeCount -eq 1 ]; then
		echo "     --> Single shapefile import mode" 
	else
		echo "     --> Multiple shapefile import mode" 
	fi
	
	IFS=$'\n'; for f in $(find ./ -iname '*.shp')
	do 
		echo "     --> Found shapefile $f..." 
		if [ $shapeCount -gt 1 ]; then
			targetTable="_src_prow_"$areaName"_"`basename $f | sed -e 's/\..*$//g' -e 's/ [A-Z][a-z]/_\l&/g' -e 's/[- ]/_/g' -e 's/[^A-Za-z0-9_]//g' -e 's/[0-9_]\([0-9_]\+\)//g' -e 's/^_//g' -e 's/_$//g' -e 's/\(_\+\)/_/g' -e 's/byway_open_to_all_traffic/boat/g' -e 's/_prow_/_/g' -e 's/_row_/_/g' | tr '[:upper:]' '[:lower:]'`
		else
			targetTable="_src_prow_"$areaName"_all"
		fi
		echo "     --> Creating SQL file for table $targetTable..." 
		shp2pgsql -s 27700 -d -W LATIN1 -N skip $f $targetTable >> $targetTable.sql 2> /dev/null
	done
	
	echo " --> Cleaning extracted files..."
	for e in */; do
		echo "     --> Deleting directory $e..."
		rm -rf "$e"
	done
	for f in `ls -I*.zip -I*.sql -Idownload-url.txt -I*.kmz -I*.kml`; do
		echo "     --> Deleting file $f..."
		rm -rf "$f"
	done
	for f in `ls -I*.zip -I*.sql -Idownload-url.txt -I*.kmz`; do
		if [ $(ls *.kmz | wc -l) -gt 0 ]; then
			echo "     --> Deleting file $f..."
			rm -rf "$f"
		fi
	done
	
	echo " --> Importing to SQL server..."
	for f in *.sql; do
		echo "     --> Importing SQL file $f..."
		psql -Ugrough-map grough-map -h 127.0.0.1 -f $f > /dev/null 
		
		IFS=$'\n'; for tableName in `echo "\dt" | psql -Ugrough-map grough-map -h 127.0.0.1 -A -t | tr '|' '\n' | grep _src_prow_$areaName`
		do
			if [ -e $fileBaseDir/$binDir/gm-import-prow-$(echo $areaName | tr '_' '-').sh ]
			then
				echo " --> Running product import script..."
				$fileBaseDir/$binDir/gm-import-prow-$(echo $areaName | tr '_' '-').sh $areaName $tableName
			fi
		done
	done
	
	echo " --> Identifying type of right of way..."
	IFS=$'\n'; for tableName in `echo "\dt" | psql -Ugrough-map grough-map -h 127.0.0.1 -A -t | tr '|' '\n' | grep _src_prow_$areaName`
	do
		tableType="Unknown"
		echo "     --> Identifying columns in $tableName..."
		psql -A -t -Ugrough-map grough-map -h 127.0.0.1 -c "SELECT column_name \
			FROM information_schema.columns WHERE table_name='"$tableName"' AND \
			data_type LIKE '%character_varying%'" >> columns_$tableName.tmp
		echo "     --> Adding column for data source..."
		psql -A -t -Ugrough-map grough-map -h 127.0.0.1 -c "ALTER TABLE "$tableName" \
			ADD COLUMN _prow_source character varying(100);" > /dev/null
		echo "     --> Adding column for right of way type..."
		psql -A -t -Ugrough-map grough-map -h 127.0.0.1 -c "ALTER TABLE "$tableName" \
			ADD COLUMN _prow_type character varying(30);" > /dev/null
			
		if [[ $tableName =~ _all ]]; then
			tableType="Unknown"
		elif [[ $tableName =~ restricted ]] || [[ $tableName =~ _rb ]]; then
			tableType="Restricted byway"
		elif [[ $tableName =~ boat ]] || [[ $tableName =~ _bt ]] || [[ $tableName =~ byway ]]; then
			tableType="Byway open to all traffic"
		elif [[ $tableName =~ bridle ]] || [[ $tableName =~ _bw ]] || [[ $tableName =~ bridel ]]; then
			tableType="Bridleway"
		elif [[ $tableName =~ permissive ]]; then
			tableType="Permissive path"
		elif [[ $tableName =~ footpath ]] || [[ $tableName =~ _fp ]]; then
			tableType="Public footpath"
		else
			tableType="Unknown"
		fi
			
		echo "     --> Table name means type is '"$tableType"'"

		echo "     --> Updating table to store source..."
		psql -A -t -Ugrough-map grough-map -h 127.0.0.1 -c "UPDATE "$tableName" \
			SET _prow_source='"$tableName"';" > /dev/null
		
		if [ ! $tableType = "Unknown" ]; then
			# Everything in this table is one type. Simple. Yipeee...
			echo "     --> Updating table to reflect type..."
			psql -A -t -Ugrough-map grough-map -h 127.0.0.1 -c "UPDATE "$tableName" \
				SET _prow_type='"$tableType"';" > /dev/null
		else
			# Now we need to check the columns of data on the table
			echo "     --> Examination of data in table required to identify types"
			IFS=$'\n'; for c in `cat columns_$tableName.tmp | grep -v _prow_`; do
				echo "         --> Running tests for column $c"
				sed -e "s/__COLUMNNAME__/"$c"/g" -e "s/__TABLENAME__/"$tableName"/g" $sqlDir/prow_identify_type_from_column.sql | psql -A -t -Ugrough-map grough-map -h 127.0.0.1
			done
		fi
		
		echo "     --> Appending data to master PRoW table..."
		psql -A -t -Ugrough-map grough-map -h 127.0.0.1 -c "INSERT INTO raw_prow \
			(geom, type, source) \
			SELECT \
				ST_Force2D((ST_Dump(geom)).geom), \
				_prow_type, \
				_prow_source \
			FROM \
				"$tableName" \
			WHERE \
				ST_GeometryType(geom) = 'ST_MultiLineString' OR ST_GeometryType(geom) = 'ST_LineString';"
	done
	
	echo " --> Removing SQL files..."
	for f in *.{sql,tmp}; do
		echo "     --> Deleting SQL file $f..."
		rm -rf "$f"
	done
	
	cd $fileBaseDir
done

echo "Populating geometry columns..."
psql -A -t -Ugrough-map grough-map -h 127.0.0.1 -c "SELECT Populate_Geometry_Columns('raw_prow'::regclass);"

echo "Updating highway authority statuses..."
psql -A -t -Ugrough-map grough-map -h 127.0.0.1 -f "$sqlDir/prow_identify_authorities.sql"

echo " --> Removing temporary tables..."
IFS=$'\n'; for tableName in `echo "\dt" | psql -Ugrough-map grough-map -h 127.0.0.1 -A -t | tr '|' '\n' | grep _src_prow`
do
	psql -A -t -Ugrough-map grough-map -h 127.0.0.1 -c "DROP TABLE IF EXISTS ${tableName}"
done

echo "--> Import complete."
