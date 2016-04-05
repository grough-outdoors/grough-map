#!/bin/bash

echo "Preparing to build places database..."

binDir=/vagrant/bin/linux
sqlDir=/vagrant/source/sql

echo "-----------------------------------"
echo "--> Importing places data..."
echo "-----------------------------------"

echo "--> Removing index..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	DROP INDEX public."Idx: place::place_geom";
	DROP INDEX public."Idx: place::place_centre_geom";
EoSQL

echo "--> Removing old data..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	TRUNCATE place;
EoSQL

echo "--> Importing OS OpenNames..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO
		place
		(
			place_name,
			place_centre_geom,
			place_geom,
			place_class_id
		)
	SELECT 
		name1,
		geom_point,
		ST_Multi(geom_bbox),
		CASE WHEN local_type = 'Village' THEN 2
			 WHEN local_type = 'City' THEN 3
			 WHEN local_type = 'Hamlet' THEN 4
			 WHEN local_type = 'Other Settlement' THEN 7
			 WHEN local_type = 'Suburban Area' THEN 5
			 WHEN local_type = 'Town' THEN 6
		END
	FROM
		_src_os_opname;
EoSQL

echo "--> Importing hills and mountains..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO
		place
		(
			place_name,
			place_centre_geom,
			place_geom,
			place_class_id
		)
	SELECT 
		"name",
		"way",
		ST_Multi(ST_Simplify(ST_Buffer("way", 300.0), 25.0)),
		CASE WHEN regexp_replace("ele", '[^0-9]', '', 'g')::double precision > 600.0 THEN 10
		     ELSE 9
		END
	FROM
		"_src_osm_point"
	WHERE
		"natural" = 'peak';
EoSQL

echo "--> Indexing and clustering..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	CREATE INDEX "Idx: place::place_centre_geom"
	  ON public.place
	  USING gist
	  (place_centre_geom);
	CREATE INDEX "Idx: place::place_geom"
	  ON public.place
	  USING gist
	  (place_geom);
	ALTER TABLE public.place CLUSTER ON "Idx: place::place_geom";
EoSQL

echo "--> Cleaning up..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	VACUUM FULL ANALYZE surface;
EoSQL

echo "--> Build complete."
