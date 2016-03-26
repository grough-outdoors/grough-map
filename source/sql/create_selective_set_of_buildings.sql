BEGIN;
DROP INDEX IF EXISTS
	"Idx: buildings::geom";
DROP TABLE IF EXISTS
	buildings;
COMMIT;

BEGIN;
CREATE TABLE
	buildings
AS
SELECT
	CASE WHEN B.Per_SV_of_OSM IS NULL THEN B.o_geom
	     WHEN B.Per_SV_of_OSM > 0.4 AND 
	          B.Per_AllOSM_of_SV > 0.8 THEN B.o_geom
	     WHEN B.Per_SV_of_OSM < 0.4 AND
	          B.Per_SV_of_OSM > 0.1 AND
	          B.Per_AllOSM_of_SV > 0.8 THEN NULL::geometry
	     WHEN B.Per_SV_of_OSM < 0.1 AND
	          B.Per_AllOSM_of_SV > 0.8 THEN B.o_geom
	     ELSE B.s_geom
	     END AS building_geom,
	CASE WHEN B.Per_SV_of_OSM IS NULL THEN 'OSM'
	     WHEN B.Per_SV_of_OSM > 0.4 AND 
	          B.Per_AllOSM_of_SV > 0.8 THEN 'OSM'
	     WHEN B.Per_SV_of_OSM < 0.4 AND
	          B.Per_SV_of_OSM > 0.1 AND
	          B.Per_AllOSM_of_SV > 0.8 THEN 'DROP'
	     WHEN B.Per_SV_of_OSM < 0.1 AND
	          B.Per_AllOSM_of_SV > 0.8 THEN 'OSM'
	     ELSE 'OML'
	     END AS building_geom_source,
	CASE WHEN B.Per_SV_of_OSM IS NULL THEN B.osm_id
	     WHEN B.Per_SV_of_OSM > 0.4 AND 
	          B.Per_AllOSM_of_SV > 0.8 THEN B.osm_id
	     WHEN B.Per_SV_of_OSM < 0.4 AND
	          B.Per_SV_of_OSM > 0.1 AND
	          B.Per_AllOSM_of_SV > 0.8 THEN NULL::bigint
	     WHEN B.Per_SV_of_OSM < 0.1 AND
	          B.Per_AllOSM_of_SV > 0.8 THEN B.osm_id
	     ELSE NULL::bigint
	     END AS building_geom_source_id,
	CASE WHEN B.Per_SV_of_OSM IS NULL THEN CASE WHEN B.o_layer IS NULL THEN 0 ELSE B.o_layer::integer END
	     WHEN B.Per_SV_of_OSM > 0.4 AND 
	          B.Per_AllOSM_of_SV > 0.6 THEN CASE WHEN B.o_layer IS NULL THEN 0 ELSE B.o_layer::integer END
	     WHEN B.Per_SV_of_OSM < 0.4 AND
	          B.Per_SV_of_OSM > 0.1 AND
	          B.Per_AllOSM_of_SV > 0.8 THEN 0::integer
	     WHEN B.Per_SV_of_OSM < 0.1 AND
	          B.Per_AllOSM_of_SV > 0.8 THEN CASE WHEN B.o_layer IS NULL THEN 0 ELSE B.o_layer::integer END
	     ELSE NULL::integer
	     END AS building_layer
FROM
(
	SELECT
		A.*,
		ST_Area( ST_Union( o2.way ) ) / ST_Area( A.s_geom ) AS Per_AllOSM_of_SV
	FROM
	(
		SELECT
			o.osm_id,
			ST_Multi(o.way) AS o_geom,
			ST_Multi(ST_MakeValid(ST_Union(ST_MakeValid(s.geom)))) AS s_geom,
			ST_Area( ST_Intersection( o.way, ST_Union(ST_MakeValid(s.geom ))) ) / ST_Area(o.way) AS Per_SV_of_OSM,
			ST_Area( ST_Intersection( o.way, ST_Union(ST_MakeValid(s.geom ))) ) / ST_Area(ST_Union(ST_MakeValid(s.geom))) AS Per_OSM_of_SV,
			o.layer AS o_layer
		FROM
			_src_osm_polygon_building o
		LEFT JOIN
			_src_os_opmplc_building s
		ON
			o.way && s.geom
		AND
			ST_Intersects( o.way, ST_MakeValid(s.geom))
		GROUP BY
			osm_id, o.way, o.layer, o.building
	) AS A
	LEFT JOIN
		_src_osm_polygon_building o2
	ON
		o2.way && A.s_geom
	AND
		ST_Intersects( o2.way, A.s_geom )
	GROUP BY
		A.osm_id, A.o_geom, A.s_geom, A.Per_SV_of_OSM, A.Per_OSM_of_SV, A.o_layer
) AS B;
COMMIT;

BEGIN;
CREATE INDEX "Idx: buildings::building_geom"
  ON buildings
  USING gist
  (building_geom);
ALTER TABLE buildings
  CLUSTER ON "Idx: buildings::building_geom";
COMMIT;

BEGIN;
INSERT INTO
	buildings
	(
		building_geom,
		building_geom_source,
		building_geom_source_id,
		building_layer
	)
SELECT
	ST_Multi(s.geom) AS building_geom,
	'OML' AS building_geom_source,
	s.gid AS building_geom_source_id,
	0::integer AS building_layer
FROM
	_src_os_opmplc_building s
LEFT JOIN
	buildings t
ON
	t.building_geom && s.geom
AND
	ST_Intersects( t.building_geom, s.geom )
WHERE
	ST_IsValid(s.geom)
AND
	t.building_geom IS NULL;
COMMIT;

BEGIN;
ALTER TABLE buildings
   ADD COLUMN building_id bigserial;
ALTER TABLE buildings
  ADD CONSTRAINT "Con: buildings::building_id" PRIMARY KEY (building_id);
COMMIT;

SELECT populate_geometry_columns('buildings'::regclass); 


