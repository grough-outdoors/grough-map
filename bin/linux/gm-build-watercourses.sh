#!/bin/bash

echo "Preparing to build watercourse database..."

binDir=/vagrant/bin/linux
sqlDir=/vagrant/source/sql

echo "-----------------------------------"
echo "--> Importing watercourse data..."
echo "-----------------------------------"

echo "--> Removing old data..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	TRUNCATE watercourse;
	DROP INDEX IF EXISTS "Idx: watercourse::watercourse_geom";
EoSQL

echo "--> Adding indices to watercourse source data..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	CREATE INDEX "Idx: _src_os_oprvrs_watercourse_link::geom"
	  ON _src_os_oprvrs_watercourse_link
	  USING gist (geom);
	CREATE INDEX "Idx: _src_os_opmplc_surface_water_line::geom"
	  ON _src_os_opmplc_surface_water_line
	  USING gist (geom);
EoSQL

echo "--> Matching streams to named watercourses..."
psql -Ugrough-map grough-map -h 127.0.0.1 -f "$sqlDir/match_opmlc_to_oprvrs.sql" > /dev/null

echo "--> Adding streams to the main database..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO
		watercourse (watercourse_name, watercourse_geom, watercourse_width, watercourse_class_id)
	SELECT
		w.name,
		ST_Multi(l.geom),
		1, -- Width
		2  -- ID
	FROM
		_src_os_opmplc_surface_water_line l
	LEFT JOIN
		opmlc_oprvrs_matching m
	ON
		m.opmlc_id = l.gid
	LEFT JOIN
		_src_os_oprvrs_watercourse_link w
	ON
		m.oprvrs_id = w.gid
EoSQL

echo "--> Adding rivers, lakes and canals to the main database..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO
		watercourse (watercourse_class_id, watercourse_width, watercourse_geom, watercourse_name)
	SELECT
		CASE WHEN form='lake' THEN 4
			 WHEN form='inlandRiver' THEN 3
			 WHEN form='canal' THEN 6
			 WHEN form='tidalRiver' THEN 1
		END AS watercourse_class_id,
		NULL AS watercourse_width,
		ST_CollectionExtract(
			ST_Multi(
				CASE WHEN Count(pm.oprvrs_id) = 0 THEN w.geom
					 ELSE ST_Difference(w.geom, ST_Buffer(ST_Collect(pm.geom_oprvrs), 1.0))
				END
			),
			2
		)AS watercourse_geom,
		w.name AS watercourse_name
	FROM
		_src_os_oprvrs_watercourse_link w
	LEFT JOIN
		opmlc_oprvrs_matching pm
	ON
		w.gid = pm.oprvrs_id
	GROUP BY
		w.gid,
		w.form,
		w.name;
EoSQL

echo "--> Calculating a minimum width for larger river systems..."
psql -Ugrough-map grough-map -h 127.0.0.1 -f "$sqlDir/calculate_widths_for_watercourses.sql" > /dev/null

# TODO: Smooth the lines somehow??

# TODO: Match against OpenStreetMap

echo "--> Extracting OSM features for watercourses..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	DROP TABLE IF EXISTS _src_osm_polygon_water;
	DROP TABLE IF EXISTS _src_osm_line_water;
	CREATE TABLE
		_src_osm_polygon_water
	AS SELECT 
		"water",
		"waterway",
		"natural",
		"landuse",
		"name",
		ST_Multi("way") AS "way"
	FROM
		_src_osm_polygon
	WHERE
		"way" IS NOT NULL AND (
			"water" IS NOT NULL OR
			"waterway" IS NOT NULL OR
			"natural"='water' OR
			"landuse"='reservoir' OR
			"landuse"='pond'
		);
	CREATE TABLE
		_src_osm_line_water
	AS SELECT 
		"water",
		"waterway",
		"natural",
		"landuse",
		"name",
		ST_Multi("way") AS "way"
	FROM
		_src_osm_line
	WHERE
		"way" IS NOT NULL AND (
			"water" IS NOT NULL OR
			"waterway" IS NOT NULL OR
			"natural"='water' OR
			"landuse"='reservoir' OR
			"landuse"='pond'
		);
	DELETE FROM _src_osm_line_water WHERE ST_GeometryType(way) <> 'ST_MultiLineString';
	SELECT populate_geometry_columns('_src_osm_polygon_water'::regclass); 
	SELECT populate_geometry_columns('_src_osm_line_water'::regclass); 
EoSQL

echo "--> Setting lakes and reservoir names from OSM where errors occured..."
psql -Ugrough-map grough-map -h 127.0.0.1 -f "$sqlDir/update_lakes_reservoirs_from_osm.sql" > /dev/null

echo "--> Removing labels from areas around the extremities of watercourses..."
psql -Ugrough-map grough-map -h 127.0.0.1 -f "$sqlDir/clean_watercourse_linear_labels.sql" > /dev/null

echo "--> Indexing and clustering..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	CREATE INDEX "Idx: watercourse::watercourse_geom"
		ON public.watercourse
		USING gist
		(watercourse_geom);
	ALTER TABLE public.watercourse 
		CLUSTER ON "Idx: watercourse::watercourse_geom";
EoSQL

echo "--> Removing temporary tables..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	DROP TABLE opmlc_oprvrs_matching;
	DROP TABLE _src_osm_polygon_water;
	DROP TABLE _src_osm_line_water;
EoSQL

echo "--> Cleaning up..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	VACUUM FULL ANALYZE watercourse;
EoSQL

echo "--> Build complete."
