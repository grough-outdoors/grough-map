#!/bin/bash

echo "Preparing to import Natural England products..."

fileBaseDirEng=/vagrant/source/natural-england/
fileBaseDirWales=/vagrant/source/nrw/
binDir=/vagrant/bin/linux/
tablePrefix=_src_zone

echo "-----------------------------------"
echo "--> Processing England..."
echo "-----------------------------------"
cd $fileBaseDirEng

echo " --> Proceeding to extract archives..."
for z in *.zip
do
	echo "     --> Extracting $z..."
	unzip -o "$z"
	if [[ $z = 'CROW_Access_Layer.zip' ]]; then
		echo "        --> Dissolving boundaries in dataset..."
		ogr2ogr CROW_Dissolved.shp CROW_Access_Layer.shp -explodecollections -dialect sqlite -sql "SELECT ST_Union(geometry) FROM 'CROW_Access_Layer' GROUP BY ''"
	fi
done

echo " --> Generating SQL files..."
echo "     --> Finding shapefiles..."
IFS=$'\n'; for f in $(find ./ -name '*.shp')
do 
	echo "         --> Found $f..." 
	baseName=`basename $f`
	reformedName=`echo $baseName | sed -e 's/\..*$//g' -e 's/[A-Z][A-Z]_//g' -e 's/[A-Z]/_\l&/g' -e 's/[^a-z0-9_]//g' -e 's/\(_\+\)/_/g'`
		
	tableName=$tablePrefix$reformedName
	echo "         --> Committing to table $tableName..." 
	if [ ! -e $tableName.sql ]
	then
		echo "DROP TABLE IF EXISTS $tableName;" > $tableName.sql
		shp2pgsql -e -s 27700 -p -W LATIN1 -N skip $f $tableName >> $tableName.sql
	fi
	shp2pgsql -e -s 27700 -a -W LATIN1 -N skip $f $tableName >> $tableName.sql
done

echo " --> Cleaning extracted files..."
for e in */
do
	echo "     --> Deleting directory $e..."
	rm -rf "$e"
done
for f in `ls -I*.zip -I*.sql`
do
	echo "     --> Deleting file $f..."
	rm -rf "$f"
done

echo " --> Importing to SQL server..."
for f in *.sql
do
	echo "     --> Importing SQL file $f..."
	psql -Ugrough-map grough-map -h 127.0.0.1 -f $f > /dev/null 
done

echo " --> Removing SQL files..."
for f in *.sql
do
	echo "     --> Deleting SQL file $f..."
	rm -rf "$f"
done

cd -

echo "-----------------------------------"
echo "--> Processing Wales..."
echo "-----------------------------------"
cd $fileBaseDirWales
tablePrefix=_src_zone_w_

echo " --> Proceeding to extract archives..."
for z in *.zip
do
	echo "     --> Extracting $z..."
	unzip -o "$z"
done

echo " --> Generating SQL files..."
echo "     --> Finding shapefiles..."
IFS=$'\n'; for f in $(find ./ -name '*.shp')
do 
	echo "         --> Found $f..." 
	baseName=`basename $f`
	reformedName=`echo $baseName | sed -e 's/\..*$//g' | tr '[:upper:]' '[:lower:]'`
		
	tableName=$tablePrefix$reformedName
	echo "         --> Committing to table $tableName..." 
	if [ ! -e $tableName.sql ]
	then
		echo "DROP TABLE IF EXISTS $tableName;" > $tableName.sql
		shp2pgsql -e -s 27700 -p -W LATIN1 -N skip $f $tableName >> $tableName.sql
	fi
	shp2pgsql -e -s 27700 -a -W LATIN1 -N skip $f $tableName >> $tableName.sql
done

echo " --> Cleaning extracted files..."
for e in */
do
	echo "     --> Deleting directory $e..."
	rm -rf "$e"
done
for f in `ls -I*.zip -I*.sql`
do
	echo "     --> Deleting file $f..."
	rm -rf "$f"
done

echo " --> Importing to SQL server..."
for f in *.sql
do
	echo "     --> Importing SQL file $f..."
	psql -Ugrough-map grough-map -h 127.0.0.1 -f $f > /dev/null 
done

echo " --> Removing SQL files..."
for f in *.sql
do
	echo "     --> Deleting SQL file $f..."
	rm -rf "$f"
done

cd -

echo "--> Intermediary tidy up..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	VACUUM FULL ANALYZE;
EoSQL

echo "--> Import complete."
