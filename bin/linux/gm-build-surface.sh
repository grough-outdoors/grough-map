#!/bin/bash

echo "Preparing to build surface database..."

binDir=/vagrant/bin/linux
sqlDir=/vagrant/source/sql

echo "-----------------------------------"
echo "--> Importing surface data..."
echo "-----------------------------------"

echo "--> Removing index..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	DROP INDEX public."Idx: surface::surface_geom";
EoSQL

echo "--> Removing old data..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	TRUNCATE surface;
EoSQL


echo "--> Importing foreshore..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO surface (surface_geom, surface_class_id)
	SELECT ST_Multi(geom), 1 FROM _src_os_opmplc_foreshore;
EoSQL

echo "--> Importing forest..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO surface (surface_geom, surface_class_id)
	SELECT ST_Multi(geom), 2 FROM _src_os_opmplc_woodland;
EoSQL

echo "--> Importing landforms..."
psql -Ugrough-map grough-map -h 127.0.0.1 -f "$sqlDir/add_vmd_ornaments_to_surface_layer.sql" > /dev/null

echo "--> Importing moorland..."
# TODO: Need to process LiDAR

echo "--> Importing airport runways and taxiways..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO
		surface (surface_geom, surface_class_id)
	SELECT
		ST_Multi(ST_Buffer(way, buffer_distance, 'endcap=flat join=mitre')) AS surface_geom,
		CASE WHEN aeroway='runway' THEN 15
			 WHEN aeroway='taxiway' THEN 14
			 ELSE NULL
		END AS surface_class_id
	FROM 
	(
	SELECT
		aeroway,
		width,
		way,
		CASE WHEN width IS NOT NULL 
				 AND regexp_replace(width, '[^0-9.]+', '')::double precision < 100 
				 AND regexp_replace(width, '[^0-9.]+', '')::double precision > 10 
			 THEN (regexp_replace(width, '[^0-9.]+', '')::double precision) / 2
			 ELSE CASE WHEN aeroway = 'taxiway' THEN 10.0
					   ELSE 25.0
				  END
		END AS buffer_distance
	FROM
		_src_osm_line
	WHERE
		aeroway IN ('runway', 'taxiway')
	) SA
EoSQL

echo "--> Importing tidal water..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO surface (surface_geom, surface_class_id)
	SELECT ST_Multi(geom), 5 FROM _src_os_opmplc_tidal_water;
EoSQL

echo "--> Importing rivers..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO surface (surface_geom, surface_class_id)
	SELECT ST_Multi(geom), 6 FROM _src_os_opmplc_surface_water_area;
EoSQL

echo "--> Importing activity areas..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO surface (surface_geom, surface_class_id)
	SELECT ST_Multi(way), 18 FROM _src_osm_polygon WHERE leisure IN ('track', 'pitch');
EoSQL

echo "--> Importing car parks..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO surface (surface_geom, surface_class_id)
	SELECT ST_Multi(way), 20 FROM _src_osm_polygon WHERE amenity IN ('parking');
EoSQL

echo "--> Importing grass..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO surface (surface_geom, surface_class_id)
	SELECT ST_Multi(way), 19 FROM _src_osm_polygon WHERE surface IN ('grass') OR landuse IN ('grass');
EoSQL

echo "--> Removing any non-polygons..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	DELETE FROM	
		surface
	WHERE
		ST_GeometryType(surface_geom) != 'ST_MultiPolygon'
	OR
		ST_GeometryType(surface_geom) IS NULL;
EoSQL

echo "--> Indexing and clustering..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	CREATE INDEX "Idx: surface::surface_geom"
	  ON public.surface
	  USING gist
	  (surface_geom);
	ALTER TABLE surface CLUSTER ON "Idx: surface::surface_geom";
EoSQL

echo "--> Adding sand beaches where applicable..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO
		surface
		(surface_geom, surface_class_id)
	SELECT
		surface_geom,
		7
	FROM
	(
		SELECT
			s.surface_id,
			ST_Multi(ST_CollectionExtract(ST_MakeValid(ST_Intersection(ST_MakeValid(s.surface_geom), ST_MakeValid(ST_Union(o.way)))), 3)) AS surface_geom
		FROM
			_src_osm_polygon o, surface s
		WHERE
			s.surface_class_id = 1
		AND
			( o.surface='sand' OR o.natural='sand' OR lower(o.name) LIKE '% sand' OR lower(o.name) LIKE '% sands' )
		AND
			o.way && s.surface_geom
		AND
			ST_Intersects(o.way, s.surface_geom)
		GROUP BY
			s.surface_id,
			s.surface_geom
	) SA;
EoSQL

echo "--> Cleaning up..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	VACUUM FULL ANALYZE surface;
EoSQL

echo "--> Build complete."
