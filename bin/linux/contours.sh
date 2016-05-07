#!/bin/bash

echo "Preparing to modify feature database..."

tileName=`echo $1 | tr '[:lower:]' '[:upper:]'`
binDir=/vagrant/bin/linux
sqlDir=/vagrant/source/sql

echo "-----------------------------------"
echo "--> Generating contour label strategy..."
echo "-----------------------------------"

echo "--> Identifying tile extent..."
tileData=`psql -Ugrough-map grough-map -h 127.0.0.1 -A -t -c "SELECT ST_XMin(tile_geom), ST_YMin(tile_geom), ST_XMax(tile_geom), ST_YMax(tile_geom) FROM grid WHERE tile_name='${tileName}'"`
IFS='|'; read -r -a tileExtent <<< "$tileData"
echo "   X min: ${tileExtent[0]}"
echo "   Y min: ${tileExtent[1]}"
echo "   X max: ${tileExtent[2]}"
echo "   Y max: ${tileExtent[3]}"

contourGeneralise=10
contourInterval=10

echo "--> Selecting contours..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	DROP TABLE IF EXISTS _tmp_contour_segments;
	DROP TABLE IF EXISTS _tmp_contour_peaks;
	DROP TABLE IF EXISTS _tmp_contour_lines;
	DROP TABLE IF EXISTS _tmp_contour_ladder_zone;
	DROP TABLE IF EXISTS _tmp_contour_label_primary;
	DROP TABLE IF EXISTS _tmp_contour_label_secondary;
	DROP TABLE IF EXISTS _tmp_contour_label_rings;

	CREATE TABLE
		_tmp_contour_segments
	AS 
	SELECT
		*
	FROM
	(
		SELECT
			e.elevation_id,
			e.elevation_level,
			ST_Simplify( e.elevation_geom, ${contourGeneralise}) AS elevation_geom,
			ST_Touches(e.elevation_geom, label_zone) AS elevation_edge
		FROM
			elevation e
		LEFT JOIN
		(
			SELECT ST_Buffer(ST_SetSRID(ST_MakeBox2D(ST_Point(${tileExtent[0]}, ${tileExtent[1]}), ST_Point(${tileExtent[2]}, ${tileExtent[3]})), 27700), 0) AS label_zone
		) z
		ON
			z.label_zone && e.elevation_geom
		AND
			ST_Intersects(z.label_zone, e.elevation_geom)
		WHERE
			e.elevation_geom && ST_Buffer(ST_SetSRID(ST_MakeBox2D(ST_Point(${tileExtent[0]}, ${tileExtent[1]}), ST_Point(${tileExtent[2]}, ${tileExtent[3]})), 27700), 0)
	) SA;


	CREATE INDEX "Idx: _tmp_contour_segments::elevation_geom"
		ON _tmp_contour_segments
		USING gist
		(elevation_geom);

	CREATE TABLE
		_tmp_contour_peaks
	AS 
	SELECT
		elevation_id,
		ST_Centroid(elevation_geom) AS elevation_geom_centroid,
		elevation_geom AS elevation_geom,
		elevation_level AS elevation_level
	FROM
	(
		SELECT
			A.elevation_id,
			A.elevation_geom,
			A.elevation_level
		FROM
			_tmp_contour_segments A
		LEFT JOIN
			_tmp_contour_segments B
		ON
			A.elevation_id != B.elevation_id
		AND
			A.elevation_geom && B.elevation_geom
		AND
			B.elevation_level > A.elevation_level
		AND
			ST_Intersects( ST_ConvexHull(A.elevation_geom), B.elevation_geom )
		AND
			ST_Length(B.elevation_geom) > 100.0
		WHERE
			A.elevation_edge = false
		AND
			ST_Length(A.elevation_geom) > 100.0
		AND
			B.elevation_id IS NULL
		ORDER BY
			A.elevation_id ASC,
			B.elevation_level DESC
	) SA;

	CREATE TABLE
		_tmp_contour_label_rings
	AS SELECT
		elevation_geom,
		elevation_level,
		-1 AS elevation_text_rotate
	FROM
		_tmp_contour_peaks;

	-- Delete any contours which don't fit our required interval
	DELETE FROM
		_tmp_contour_segments
	WHERE
		round(elevation_level)::integer % ${contourInterval} != 0;
EoSQL

echo "--> Building contour labels..."
psql -Ugrough-map grough-map -h 127.0.0.1 -f "$sqlDir/build_contours_for_current_tile.sql" > /dev/null

cd $currentDir
