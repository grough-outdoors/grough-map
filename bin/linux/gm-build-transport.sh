#!/bin/bash

echo "Preparing to build transport database..."

binDir=/vagrant/bin/linux
sqlDir=/vagrant/source/sql
for s in $binDir/gm-build-transport-*
do
	dos2unix $s
done

echo "Testing requirements..."
set -e
"${binDir}/gm-require-db.sh" osm line
"${binDir}/gm-require-db.sh" prow
"${binDir}/gm-require-db.sh" os oproad
set +e

echo "-----------------------------------"
echo "--> Extracting OSM highways data..."
echo "-----------------------------------"

echo "--> Creating generalised subset table for highways..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	DROP TABLE IF EXISTS _src_osm_line_transport;
	CREATE TABLE
		_src_osm_line_transport
	AS SELECT
		*
	FROM
		_src_osm_line
	WHERE
		highway IS NOT NULL OR railway IS NOT NULL;
EoSQL
 > /dev/null
	
echo "--> Adding indices..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	CREATE INDEX "Idx: _src_osm_line_transport::way"
	   ON _src_osm_line_transport USING gist (way);
EoSQL
 > /dev/null

echo "--> Clustering spatially..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	ALTER TABLE _src_osm_line_transport
	  CLUSTER ON "Idx: _src_osm_line_transport::way";
EoSQL
 > /dev/null

echo "--> Cleaning up..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	VACUUM FULL ANALYZE _src_osm_line_transport;
EoSQL
 > /dev/null

echo "-----------------------------------"
echo "--> Creating base highway dataset from OSM..."
echo "-----------------------------------"
echo "--> Removing spatial index on edges..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	DROP INDEX IF EXISTS "Idx: edge::edge_geom";
EoSQL
echo "--> Truncating edges..."	
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	TRUNCATE edge;
EoSQL
echo "--> Vacuuming..."	
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	VACUUM FULL edge;
EoSQL

echo "--> Generating base data from highways..."
sed -e "s/__COLUMNNAME__/highway/g" "$sqlDir/create_base_from_osm.sql" | psql -Ugrough-map grough-map -h 127.0.0.1
echo "--> Adding railway data..."
sed -e "s/__COLUMNNAME__/railway/g" "$sqlDir/create_base_from_osm.sql" | psql -Ugrough-map grough-map -h 127.0.0.1

echo "--> Indexing..."	
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	CREATE INDEX "Idx: edge::edge_geom"
	   ON edge USING gist (edge_geom);
EoSQL
echo "--> Clustering..."	
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	ALTER TABLE edge
	  CLUSTER ON "Idx: edge::edge_geom";
EoSQL
echo "--> Vacuuming and analyzing..."	
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	VACUUM FULL ANALYZE edge;
EoSQL
echo "--> Registering geometry column..."	
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	SELECT Populate_Geometry_Columns('edge'::regclass);
EoSQL


echo "-----------------------------------"
echo "--> Importing OS Open Roads for gaps and correction..."
echo "-----------------------------------"
echo "--> Identifying matches between OS Open Roads and existing edges..."
psql -Ugrough-map grough-map -h 127.0.0.1 -f "$sqlDir/match_base_to_oproad.sql" > /dev/null
echo "--> Updating and adding edges from OS Open Roads..."
psql -Ugrough-map grough-map -h 127.0.0.1 -f "$sqlDir/add_to_base_from_unmatched_openroads.sql" > /dev/null
echo "--> Vacuuming..."	
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	ALTER TABLE edge
	  CLUSTER ON "Idx: edge::edge_geom";
	VACUUM FULL ANALYZE edge;
EoSQL

echo "-----------------------------------"
echo "--> Importing LA PRoW datasets..."
echo "-----------------------------------"
echo "--> Calculating point spacing for existing edges..."	
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	ALTER TABLE _src_osm_line_transport DROP COLUMN IF EXISTS point_spacing;
	ALTER TABLE _src_osm_line_transport ADD COLUMN point_spacing double precision;
	UPDATE _src_osm_line_transport SET point_spacing=ST_Length(way)/ST_NPoints(way);
EoSQL
echo "--> Identifying matches between PRoW and existing edges..."
psql -Ugrough-map grough-map -h 127.0.0.1 -f "$sqlDir/match_base_to_prow.sql" > /dev/null
echo "--> Updating and adding edges from PRoW datasets..."
psql -Ugrough-map grough-map -h 127.0.0.1 -f "$sqlDir/add_to_base_from_unmatched_prow.sql" > /dev/null
echo "--> Erasing temporary tables..."	
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	DROP TABLE IF EXISTS edge_prow_additions;
	DROP TABLE IF EXISTS edge_prow_matching;
EoSQL
echo "--> Vacuuming..."	
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	ALTER TABLE edge
	  CLUSTER ON "Idx: edge::edge_geom";
	VACUUM FULL ANALYZE edge;
EoSQL

echo "-----------------------------------"
echo "--> Final steps..."
echo "-----------------------------------"
echo "--> Clustering edges..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	CLUSTER VERBOSE edge;
EoSQL

echo "--> Cleaning..."
"$binDir/gm-clean-sources.sh"

echo "--> Build complete."
