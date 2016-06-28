#!/bin/bash

echo "Preparing to build watercourse database..."

binDir=/vagrant/bin/linux
sqlDir=/vagrant/source/sql

echo "Testing requirements..."
set -e
"${binDir}/gm-require-db.sh" osm line
"${binDir}/gm-require-db.sh" os oprvrs
"${binDir}/gm-require-db.sh" os opmplc
set +e

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
		CASE WHEN w.name1_lang = 'eng' THEN w.name1
		     WHEN w.name2_lang = 'eng' THEN w.name2
			 ELSE w.name1
		END AS name,
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
		CASE WHEN w.name1_lang = 'eng' THEN w.name1
		     WHEN w.name2_lang = 'eng' THEN w.name2
			 ELSE w.name1
		END AS watercourse_name
	FROM
		_src_os_oprvrs_watercourse_link w
	LEFT JOIN
		opmlc_oprvrs_matching pm
	ON
		w.gid = pm.oprvrs_id
	GROUP BY
		w.gid,
		w.form,
		w.name1,
		w.name2;
EoSQL

echo "--> Indexing and clustering..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	CREATE INDEX "Idx: watercourse::watercourse_geom"
		ON public.watercourse
		USING gist
		(watercourse_geom);
	ALTER TABLE public.watercourse 
		CLUSTER ON "Idx: watercourse::watercourse_geom";
EoSQL

echo "--> Preparing to calculate minimum widths..."
psql -Ugrough-map grough-map -h 127.0.0.1 -f "$sqlDir/calculate_widths_for_watercourses.sql"

echo "--> Vacuuming..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	VACUUM;
EoSQL

echo "--> Calculating a minimum width for larger river systems..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
-- Update widths
BEGIN;
CREATE TABLE
	_tmp_new_watercourse_widths
AS
	SELECT
		watercourse_id,
		Avg(watercourse_distance) AS watercourse_avg_distance,
		Min(watercourse_distance) AS watercourse_min_distance
	FROM
	(
		SELECT
			SA.watercourse_id,
			greatest(1, ST_Distance( SA.watercourse_point, ST_Boundary(s.surface_geom) )) AS watercourse_distance
		FROM
		(
			SELECT
				watercourse_id,
				ST_Line_Interpolate_Point((ST_Dump(watercourse_geom)).geom, z::numeric / 100) AS watercourse_point
			FROM
				_tmp_surface_coarse
			LEFT JOIN 
				generate_series(0, 100, 10) AS z
			ON 
				true
		) SA
		LEFT JOIN
			_tmp_surface_coarse s
		ON
			SA.watercourse_id = s.watercourse_id
	) SB
	GROUP BY
		watercourse_id;
COMMIT;

BEGIN;
UPDATE
	watercourse
SET
	watercourse_width = SC.watercourse_avg_distance
FROM 
	_tmp_new_watercourse_widths SC
WHERE
	SC.watercourse_id = watercourse.watercourse_id;
COMMIT;
EoSQL

# TODO: Smooth the lines somehow??

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

echo "--> Setting lakes and reservoir names from OSM where weirdness occured..."
psql -Ugrough-map grough-map -h 127.0.0.1 -f "$sqlDir/update_lakes_reservoirs_from_osm.sql" > /dev/null

echo "--> Naming watercourses using OS OpenMap Local where possible..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	UPDATE
		watercourse w
	SET
		watercourse_name = SB.watercourse_new_name
	FROM
	(
		SELECT
			watercourse_id,
			first(watercourse_old_name) AS watercourse_old_name,
			first(watercourse_new_name) AS watercourse_new_name,
			first(watercourse_point_distance) AS watercourse_point_distance
		FROM
		(
			SELECT
				w.watercourse_id,
				watercourse_name AS watercourse_old_name,
				p.distname AS watercourse_new_name,
				ST_Distance(w.watercourse_geom, p.geom) AS watercourse_point_distance
			FROM
				_src_os_opmplc_named_place p, watercourse w
			WHERE
				ST_DWithin(w.watercourse_geom, p.geom, 30.0)
			AND
				p.classifica = 'Hydrography'
			ORDER BY
				w.watercourse_id ASC,
				ST_Distance(w.watercourse_geom, p.geom) ASC
		) SA
		GROUP BY
			watercourse_id
		HAVING
			first(watercourse_old_name) IS NULL
	) SB
	WHERE
		SB.watercourse_id = w.watercourse_id;
EoSQL

echo "--> Removing labels from areas around the extremities of watercourses..."
psql -Ugrough-map grough-map -h 127.0.0.1 -f "$sqlDir/clean_watercourse_linear_labels.sql" > /dev/null

echo "--> Removing temporary tables..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	DROP TABLE opmlc_oprvrs_matching;
	DROP TABLE _src_osm_polygon_water;
	DROP TABLE _src_osm_line_water;
	DROP TABLE _tmp_surface_coarse;
	DROP TABLE _tmp_surface_water;
	DROP TABLE _tmp_new_watercourse_widths;
EoSQL

echo "--> Cleaning up..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	VACUUM FULL ANALYZE watercourse;
EoSQL

echo "--> Cleaning..."
"$binDir/gm-clean-sources.sh"

echo "--> Build complete."
