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

	echo "--> Adding assumed attributions..."
	gm-require-attribution "/vagrant/source/lidar/attribution_ea.json"
	gm-require-attribution "/vagrant/source/lidar/attribution_nrw.json"

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


elif [ "$dataType" = "OBSTRUCTIONS" ]; then
	echo "--> Removing existing raw obstruction data..."
	psql -Ugrough-map grough-map -h 127.0.0.1 -c "TRUNCATE TABLE raw_obstructions;"
	echo "--> Vacuuming tables..."
	psql -Ugrough-map grough-map -h 127.0.0.1 -c "VACUUM FULL ANALYZE raw_obstructions;"
	echo "--> Restoring obstructions from raw_obstructions..."
	pg_restore -Ugrough-map -d grough-map -h 127.0.0.1 -Fc -a raw_obstructions.bak
	<<IGNORE
	if [ `ls obstructions-*.bak | wc -l` -gt 0 ]; then
		psql -Ugrough-map grough-map -h 127.0.0.1 -c "CREATE TABLE _tmp_obstruction_prev ( obs_geom geometry(MultiLineString,27700) );"
		psql -Ugrough-map grough-map -h 127.0.0.1 -c "INSERT INTO _tmp_obstruction_prev (obs_geom) SELECT obs_geom FROM raw_obstructions;"
		psql -Ugrough-map grough-map -h 127.0.0.1 -c "TRUNCATE raw_obstructions;"
		for fn in obstructions-*.bak; 
		do
			echo "--> Restoring obstructions from ${fn}..."
			pg_restore -Ugrough-map -d grough-map -h 127.0.0.1 -Fc -a ${fn}
			psql -Ugrough-map grough-map -h 127.0.0.1 -c "INSERT INTO _tmp_obstruction_prev (obs_geom) SELECT obs_geom FROM raw_obstructions;"
			psql -Ugrough-map grough-map -h 127.0.0.1 -c "TRUNCATE raw_obstructions;"
		done
		echo "--> Inserting back into main table..."
		psql -Ugrough-map grough-map -h 127.0.0.1 -c "INSERT INTO raw_obstructions (obs_geom) SELECT obs_geom FROM _tmp_obstruction_prev;"
		echo "--> Removing temporary table..."
		psql -Ugrough-map grough-map -h 127.0.0.1 -c "DROP TABLE _tmp_obstruction_prev;"
	fi
IGNORE
	echo "--> Adding assumed attributions..."
	gm-require-attribution "/vagrant/source/lidar/attribution_ea.json"
	gm-require-attribution "/vagrant/source/lidar/attribution_nrw.json"

	echo "--> Vacuuming tables..."
	psql -Ugrough-map grough-map -h 127.0.0.1 -c "VACUUM raw_obstructions;"

else
	echo "Unrecognised restore archive request."
fi

echo ""
echo "Import complete."
cd - > /dev/null 2> /dev/null
