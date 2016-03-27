#!/bin/bash

echo "Preparing to build building database..."

binDir=/vagrant/bin/linux
sqlDir=/vagrant/source/sql

echo "-----------------------------------"
echo "--> Extracting OSM buildings data..."
echo "-----------------------------------"

echo "--> Creating generalised subset table for buildings..."
psql -Ugrough-map grough-map -h 127.0.0.1 -f "$sqlDir/prepare_building_tables.sql" > /dev/null

echo "--> Cleaning up..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	VACUUM FULL ANALYZE _src_os_opmplc_building;
EoSQL
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	VACUUM FULL ANALYZE _src_osm_polygon_building;
EoSQL

echo "-----------------------------------"
echo "--> Creating base building dataset..."
echo "-----------------------------------"
echo "--> Creating generalised subset table for buildings..."
psql -Ugrough-map grough-map -h 127.0.0.1 -f "$sqlDir/create_selective_set_of_buildings.sql" > /dev/null

echo "--> Cleaning up..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	VACUUM FULL ANALYZE buildings;
EoSQL


echo "-----------------------------------"
echo "--> Ensuring validity of features..."
echo "-----------------------------------"
echo "--> Removing invalid geometries..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	DELETE FROM
		buildings
	WHERE
		ST_GeometryType(building_geom) != 'ST_MultiPolygon';

	UPDATE
		buildings
	SET
		building_geom = ST_MakeValid(building_geom);
EoSQL

echo "-----------------------------------"
echo "--> Filling significant gaps with OS data..."
echo "-----------------------------------"
echo "--> Creating generalised subset table for buildings..."
psql -Ugrough-map grough-map -h 127.0.0.1 -f "$sqlDir/add_missing_parts_of_buildings.sql" > /dev/null

echo "--> Clustering..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	ALTER TABLE public.buildings CLUSTER VERBOSE ON "Idx: buildings::building_geom";
EoSQL

echo "--> Cleaning up..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	VACUUM FULL buildings;
EoSQL

echo "--> Build complete."
