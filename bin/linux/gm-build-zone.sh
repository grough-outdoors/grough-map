#!/bin/bash

echo "Preparing to build zone database..."

binDir=/vagrant/bin/linux
sqlDir=/vagrant/source/sql

echo "Testing requirements..."
set -e
"${binDir}/gm-require-db.sh" zone national_parks
"${binDir}/gm-require-db.sh" zone c_r_dissolved
"${binDir}/gm-require-db.sh" zone c_r_access_layer
"${binDir}/gm-require-db.sh" zone doorstep_greens_polygons
"${binDir}/gm-require-db.sh" zone millennium_greens
"${binDir}/gm-require-db.sh" zone country_parks_england
"${binDir}/gm-require-db.sh" zone w_country_parkpolygon
"${binDir}/gm-require-db.sh" zone w_nrw_crow_dedicated_landpolygon
"${binDir}/gm-require-db.sh" zone w_national_parkspolygon
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
echo "    --> England..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO zone (zone_class_id, zone_geom)
	SELECT
		1, geom
	FROM (
		SELECT
			ST_Multi(ST_MakeValid((ST_Dump(geom)).geom)) AS geom
		FROM _src_zone_c_r_dissolved
	) SA
EoSQL
echo "    --> Wales..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO zone (zone_class_id, zone_geom)
	SELECT
		1, geom
	FROM (
		SELECT
			ST_Multi(ST_MakeValid((ST_Dump(geom)).geom)) AS geom
		FROM _src_zone_w_nrw_crow_dedicated_landpolygon
	) SA
EoSQL

echo "--> Adding national parks..."
echo "    --> England..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO zone (zone_class_id, zone_geom)
	SELECT
		3, geom
	FROM (
		SELECT
			ST_MakeValid(geom) AS geom
		FROM _src_zone_national_parks
	) SA
EoSQL
echo "    --> Wales..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO zone (zone_class_id, zone_geom)
	SELECT
		3, geom
	FROM (
		SELECT
			ST_MakeValid(geom) AS geom
		FROM _src_zone_w_national_parkspolygon
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
#		FROM _src_zone_c_r_access_layer GROUP BY true
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
		FROM _src_zone_doorstep_greens_polygons
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
		FROM _src_zone_millennium_greens
	) SA
EoSQL

echo "--> Adding country parks..."
echo "    --> England..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO zone (zone_class_id, zone_geom)
	SELECT
		7, geom
	FROM (
		SELECT
			ST_MakeValid(geom) AS geom
		FROM _src_zone_country_parks_england 
	) SA
EoSQL
echo "    --> Wales..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO zone (zone_class_id, zone_geom)
	SELECT
		7, geom
	FROM (
		SELECT
			ST_MakeValid(geom) AS geom
		FROM _src_zone_w_country_parkpolygon 
	) SA
EoSQL

echo "--> Adding boundaries..."
echo "    --> Unitary..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO 
		zone
		(zone_class_id, zone_name, zone_geom)
	SELECT
		CASE WHEN descriptio = 'District' THEN 13
			 WHEN descriptio = 'London Borough' THEN 12
			 WHEN descriptio = 'Metropolitan District' THEN 11
			 WHEN descriptio = 'Unitary Authority' THEN 9
		END AS zone_class_id,
		regexp_replace(
			regexp_replace(
				trim("name"), 
				'(^(City and County of the|City of|County of|The City of) |( (District|London Boro|City)|)($| \(B\))$)', 
				'', 
				'g'
			),
			'^(.*) - ',
			'',
			'g'
		) AS zone_name,
		"geom" AS zone_geom
	FROM
		_src_os_bdline_district_borough_unitary_region;
EoSQL
echo "    --> County..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO 
		zone
		(zone_class_id, zone_name, zone_geom) 
	SELECT
		10 AS zone_class_id,
		regexp_replace(
			trim("name"), 
			' County$', 
			'', 
			'g'
		) AS zone_name,
		"geom" AS zone_geom
	FROM
		_src_os_bdline_county_region
	WHERE
		"name" LIKE '% County';
EoSQL
echo "    --> Highway authorities..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO 
		"zone"
		(zone_class_id, zone_name, zone_geom) 
	SELECT
		8 AS zone_class_id,
		"zone_name" AS zone_name,
		"zone_geom" AS zone_geom
	FROM
		"zone"
	WHERE
		zone_class_id IN (9, 10, 11, 12);
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
