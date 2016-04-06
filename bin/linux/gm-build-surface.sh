#!/bin/bash

echo "Preparing to build surface database..."

binDir=/vagrant/bin/linux
sqlDir=/vagrant/source/sql

echo "-----------------------------------"
echo "--> Importing surface data..."
echo "-----------------------------------"

echo "--> Removing index..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	DROP INDEX public."Idx: surface::surface_geom";
EoSQL

echo "--> Removing old data..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	TRUNCATE surface;
EoSQL


echo "--> Importing foreshore..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO surface (surface_geom, surface_class_id)
	SELECT ST_Multi(geom), 1 FROM _src_os_opmplc_foreshore;
EoSQL

echo "--> Importing forest..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO surface (surface_geom, surface_class_id)
	SELECT ST_Multi(geom), 2 FROM _src_os_opmplc_woodland;
EoSQL

echo "--> Importing landforms..."
psql -Ugrough-map grough-map -h 127.0.0.1 -f "$sqlDir/add_vmd_ornaments_to_surface_layer.sql" > /dev/null

echo "--> Importing moorland..."
# TODO: Need to process LiDAR

echo "--> Importing tidal water..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO surface (surface_geom, surface_class_id)
	SELECT ST_Multi(geom), 5 FROM _src_os_opmplc_tidal_water;
EoSQL

echo "--> Importing rivers..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO surface (surface_geom, surface_class_id)
	SELECT ST_Multi(geom), 6 FROM _src_os_opmplc_surface_water_area;
EoSQL

echo "--> Removing any non-polygons..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	DELETE FROM	
		surface
	WHERE
		ST_GeometryType(surface_geom) != 'ST_MultiPolygon'
	OR
		ST_GeometryType(surface_geom) IS NULL;
EoSQL

echo "--> Indexing and clustering..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	CREATE INDEX "Idx: surface::surface_geom"
	  ON public.surface
	  USING gist
	  (surface_geom);
	ALTER TABLE surface CLUSTER ON "Idx: surface::surface_geom";
EoSQL

echo "--> Cleaning up..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	VACUUM FULL ANALYZE surface;
EoSQL

echo "--> Build complete."
