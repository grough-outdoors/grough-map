#!/bin/bash

echo "Preparing to restore archived built feature data..."
dataType=`echo $1 | tr '[:lower:]' '[:upper:]'`

echo "-----------------------------------"
echo "--> Restoring data..."
echo "-----------------------------------"
cd /vagrant/archive/

if [ "$dataType" = "ELEVATION" ]; then
	echo "--> Removing existing elevation data..."
	psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	TRUNCATE TABLE elevation;
	TRUNCATE TABLE elevation_source;
EoSQL
	echo "--> Vacuuming tables..."
	psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	VACUUM FULL ANALYZE elevation;
	VACUUM FULL ANALYZE elevation_source;
EoSQL
	echo "--> Restoring elevation..."
	pg_restore -Ugrough-map -d grough-map -h 127.0.0.1 -Fc -a elevation.bak
	echo "--> Restoring elevation sources..."
	pg_restore -Ugrough-map -d grough-map -h 127.0.0.1 -Fc -a elevation_source.bak
	echo "--> Vacuuming tables..."
	psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	VACUUM FULL ANALYZE elevation;
	VACUUM FULL ANALYZE elevation_source;
EoSQL

elif [ "$dataType" = "SURFACE" ]; then
	echo "--> Removing existing surface data..."
	psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	TRUNCATE TABLE surface;
EoSQL
	echo "--> Vacuuming tables..."
	psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	VACUUM FULL ANALYZE surface;
EoSQL
	echo "--> Restoring surface..."
	pg_restore -Ugrough-map -d grough-map -h 127.0.0.1 -Fc -a surface.bak
	echo "--> Vacuuming tables..."
	psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	VACUUM FULL ANALYZE surface;
EoSQL

else
	echo "Unrecognised restore archive request."
fi

echo ""
echo "Import complete."
cd - > /dev/null 2> /dev/null
