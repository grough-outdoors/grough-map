#!/bin/bash

echo "Preparing to build places database..."

binDir=/vagrant/bin/linux
sqlDir=/vagrant/source/sql

echo "Testing requirements..."
set -e
"${binDir}/gm-require-db.sh" osm polygon
"${binDir}/gm-require-db.sh" os opname
set +e

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

echo "--> Extracting places from OSM data..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	DROP TABLE IF EXISTS _src_osm_polygon_place;
	CREATE TABLE
		_src_osm_polygon_place
	AS SELECT
		"name",
		ST_Multi(ST_MakeValid("way")) AS "way"
	FROM
		_src_osm_polygon
	WHERE
		( "place" IS NOT NULL OR "boundary" IS NOT NULL )
	AND
		ST_GeometryType("way") LIKE '%Polygon';

	SELECT populate_geometry_columns('_src_osm_polygon_place'::regclass); 
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
		("natural" = 'peak' OR "natural" = 'fell')
	AND
		"name" IS NOT NULL;
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

echo "--> Clipping using watercourses..."
psql -Ugrough-map grough-map -h 127.0.0.1 -f "$sqlDir/clip_places_using_watercourses.sql" > /dev/null

echo "--> Adding waterbodies from existing data..."
psql -Ugrough-map grough-map -h 127.0.0.1 -f "$sqlDir/add_waterbodies_to_places.sql" > /dev/null

echo "--> Adding waterbodies from OSM..."
psql -Ugrough-map grough-map -h 127.0.0.1 -f "$sqlDir/add_osm_waterbodies_to_places.sql" > /dev/null

echo "--> Disabling linear labels for small waterbodies..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	UPDATE
		watercourse w
	SET
		watercourse_allow_linear_label = false
	FROM
	(
		SELECT
			w.watercourse_id
		FROM
			place p, watercourse w
		WHERE
			p.place_class_id = 12
		AND
			w.watercourse_class_id IN (4, 5)
		AND
			p.place_geom && w.watercourse_geom
		AND
			ST_Intersects(p.place_geom, w.watercourse_geom)
	) SA
	WHERE
		SA.watercourse_id = w.watercourse_id;
EoSQL

echo " --> Identifying columns to check for place imports..."
IFS=$'\n'; for columnName in `psql -Ugrough-map grough-map -h 127.0.0.1 -A -t -c "SELECT DISTINCT import_field FROM place_import"`
do
	echo "    --> Found column: ${columnName}..."
	echo "       --> Importing polygons..."
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
			o.name AS place_name,
			ST_Centroid(way) AS place_centre_geom,
			ST_Multi(ST_MakeValid(ST_Simplify(way, 10.0))) AS place_geom,
			i.import_class_id AS place_class_id
		FROM
			_src_osm_polygon o
		INNER JOIN
			place_import i
		ON
			o.${columnName} = i.import_value
		AND
			o.name IS NOT NULL
		AND
			( o.building IS NULL OR o.building = 'no' )
		AND
			looks_like_a_name(o.name) = true;
EoSQL
done

echo "--> Removing invalid names..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
DELETE FROM
	place
WHERE
	looks_like_a_name(place_name) = false;
EoSQL

echo "--> Removing duplicates..."
psql -Ugrough-map grough-map -h 127.0.0.1 -f "$sqlDir/merge_duplicate_places.sql" > /dev/null

echo "--> Removing invalid geometries..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
DELETE FROM
	place
WHERE
	ST_NumGeometries(ST_Multi(ST_CollectionExtract("place_geom", 3))) = 0
OR
	ST_GeometryType("place_geom") NOT LIKE '%Polygon'
OR
	ST_IsEmpty("place_geom") = true;

UPDATE
	place
SET
	place_geom = ST_Multi(ST_MakeValid(ST_Buffer(ST_CollectionExtract("place_geom", 3), 0.01)))
WHERE
	ST_IsEmpty(ST_CollectionExtract("place_geom", 3)) = false;
	
DELETE FROM
	place
WHERE
	ST_IsValid("place_geom") = false;
EoSQL

echo "--> Removing temporary tables..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	DROP TABLE IF EXISTS _src_osm_polygon_place;
EoSQL

echo "--> Cleaning up..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	VACUUM FULL ANALYZE place;
EoSQL

echo "--> Build complete."
