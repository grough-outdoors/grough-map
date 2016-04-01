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

# TODO: Match against OpenStreetMap

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

# TODO: Match against polygons

# TODO: Add centrelines for polygons

# TODO: Smooth the lines somehow??

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
#psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
#	DROP TABLE opmlc_oprvrs_matching;
#EoSQL

echo "--> Cleaning up..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	VACUUM FULL ANALYZE watercourse;
EoSQL

echo "--> Build complete."
