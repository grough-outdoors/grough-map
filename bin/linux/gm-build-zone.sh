#!/bin/bash

echo "Preparing to build zone database..."

binDir=/vagrant/bin/linux
sqlDir=/vagrant/source/sql

echo "Testing requirements..."
set -e
"${binDir}/gm-require-db.sh" ne national_parks
"${binDir}/gm-require-db.sh" ne c_r_dissolved
"${binDir}/gm-require-db.sh" ne c_r_access_layer
"${binDir}/gm-require-db.sh" ne doorstep_greens_polygons
"${binDir}/gm-require-db.sh" ne millennium_greens
"${binDir}/gm-require-db.sh" ne country_parks_england
set +e

echo "-----------------------------------"
echo "--> Importing zone data..."
echo "-----------------------------------"

echo "--> Removing old data..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	TRUNCATE zone;
	DROP INDEX IF EXISTS "Idx: zone::zone_geom";
EoSQL

echo "--> Adding CRoW Access Layer..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO zone (zone_class_id, zone_geom)
	SELECT
		1, geom
	FROM (
		SELECT
			ST_Multi(ST_MakeValid((ST_Dump(geom)).geom)) AS geom
		FROM _src_ne_c_r_dissolved
	) SA
EoSQL

echo "--> Adding national parks..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO zone (zone_class_id, zone_geom)
	SELECT
		3, geom
	FROM (
		SELECT
			ST_MakeValid(geom) AS geom
		FROM _src_ne_national_parks
	) SA
EoSQL

echo "--> Adding nature reserves..."
#psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
#	INSERT INTO zone (zone_class_id, zone_geom)
#	SELECT
#		4, geom
#	FROM (
#		SELECT
#			(ST_Dump(ST_Union(ST_MakeValid(geom)))).geom
#		FROM _src_ne_c_r_access_layer GROUP BY true
#	) SA
#EoSQL

echo "--> Adding doorstep greens..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO zone (zone_class_id, zone_geom)
	SELECT
		5, geom
	FROM (
		SELECT
			ST_MakeValid(geom) AS geom
		FROM _src_ne_doorstep_greens_polygons
	) SA
EoSQL

echo "--> Adding millennium greens..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO zone (zone_class_id, zone_geom)
	SELECT
		6, geom
	FROM (
		SELECT
			ST_MakeValid(geom) AS geom
		FROM _src_ne_millennium_greens
	) SA
EoSQL

echo "--> Adding country parks..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO zone (zone_class_id, zone_geom)
	SELECT
		7, geom
	FROM (
		SELECT
			ST_MakeValid(geom) AS geom
		FROM _src_ne_country_parks_england 
	) SA
EoSQL

echo "--> Removing dodgy geometries..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	UPDATE "zone" SET "zone_geom" = ST_MakeValid(ST_Simplify("zone_geom", 1.2));
	DELETE FROM "zone" WHERE ST_Area("zone_geom") < 1.0;
EoSQL

echo "--> Removing small holes..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	UPDATE "zone" SET "zone_geom" = ST_Multi(filter_rings("zone_geom", 250));
EoSQL

echo "--> Indexing and clustering..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	CREATE INDEX "Idx: zone::zone_geom"
		ON zone
		USING gist
		(zone_geom);
	ALTER TABLE zone CLUSTER ON "Idx: zone::zone_geom";
EoSQL

# TODO: Remove duplicates

echo "--> Cleaning up..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	VACUUM FULL ANALYZE zone;
EoSQL

echo "--> Cleaning..."
"$binDir/gm-clean-sources.sh"

echo "--> Build complete."
