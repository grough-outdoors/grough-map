#!/bin/bash

echo "Preparing to modify feature database..."

tileName=`echo $1 | tr '[:lower:]' '[:upper:]'`
binDir=/vagrant/bin/linux
sqlDir=/vagrant/source/sql

echo "-----------------------------------"
echo "--> Importing obstructions as features..."
echo "-----------------------------------"

echo "--> Identifying tile extent..."
tileData=`psql -Ugrough-map grough-map -h 127.0.0.1 -A -t -c "SELECT ST_XMin(tile_geom), ST_YMin(tile_geom), ST_XMax(tile_geom), ST_YMax(tile_geom) FROM grid WHERE tile_name='${tileName}'"`
IFS='|'; read -r -a tileExtent <<< "$tileData"
echo "   X min: ${tileExtent[0]}"
echo "   Y min: ${tileExtent[1]}"
echo "   X max: ${tileExtent[2]}"
echo "   Y max: ${tileExtent[3]}"

echo "--> Removing old data..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	BEGIN;
	DROP TABLE IF EXISTS _tmp_raw_obstructions;
	DROP TABLE IF EXISTS _tmp_raw_obstructions_joins_self;
	DROP TABLE IF EXISTS _tmp_raw_obstructions_joins_highway;
	DROP TABLE IF EXISTS _tmp_raw_obstructions_highway;
	COMMIT;

	BEGIN;
	CREATE TABLE _tmp_raw_obstructions AS
	SELECT
		obs_id AS src_id,
		(ST_Dump(obs_geom)).geom AS geom
	FROM
		raw_obstructions
	WHERE
		obs_geom && ST_MakeBox2D(ST_Point(${tileExtent[0]}, ${tileExtent[1]}), ST_Point(${tileExtent[2]}, ${tileExtent[3]}));

	CREATE TABLE _tmp_raw_obstructions_highway AS
	SELECT
		edge_id AS src_id,
		(ST_Dump(edge_geom)).geom AS geom
	FROM
		edge
	WHERE
		edge_geom && ST_MakeBox2D(ST_Point(${tileExtent[0]}, ${tileExtent[1]}), ST_Point(${tileExtent[2]}, ${tileExtent[3]}));
	COMMIT;
EoSQL

echo "--> Building clean data..."
psql -Ugrough-map grough-map -h 127.0.0.1 -f "$sqlDir/raw_obstructions_join_nearby.sql"

echo "--> Removing existing features..."
# Class 52 = Obstruction
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	DELETE FROM
		feature_linear 
	WHERE
		feature_class_id = 52
	AND
		feature_geom && ST_MakeBox2D(ST_Point(${tileExtent[0]}, ${tileExtent[1]}), ST_Point(${tileExtent[2]}, ${tileExtent[3]}));
EoSQL

# TODO: Select only entities which don't overlap with existing wall geometries

echo "--> Adding new features..."
# Class 52 = Obstruction
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO
		feature_linear 
		(feature_geom, feature_class_id)
	SELECT
		ST_Multi(geom),
		52
	FROM (
		SELECT geom FROM _tmp_raw_obstructions
		UNION SELECT geom FROM _tmp_raw_obstructions_joins_highway
		UNION SELECT geom FROM _tmp_raw_obstructions_joins_self
	) SA
	LEFT JOIN
	(
		SELECT
			ST_Union(ST_Buffer(f.feature_geom, 25.0)) AS delete_zone
		FROM
			feature_linear f
		WHERE
			f.feature_geom && ST_MakeBox2D(ST_Point(${tileExtent[0]}, ${tileExtent[1]}), ST_Point(${tileExtent[2]}, ${tileExtent[3]}))
		AND
			f.feature_class_id IN (1, 2, 3, 5, 6, 20)
	) SB
	ON 
		ST_Within(SA.geom, SB.delete_zone)
	WHERE
		SB.delete_zone IS NULL;
EoSQL

echo "--> Removing old data..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	DROP TABLE IF EXISTS _tmp_raw_obstructions;
	DROP TABLE IF EXISTS _tmp_raw_obstructions_joins_self;
	DROP TABLE IF EXISTS _tmp_raw_obstructions_joins_highway;
	DROP TABLE IF EXISTS _tmp_raw_obstructions_highway;
	DROP TABLE IF EXISTS _tmp_raw_obstructions_highway_zones;
EoSQL

echo "--> Build complete."
