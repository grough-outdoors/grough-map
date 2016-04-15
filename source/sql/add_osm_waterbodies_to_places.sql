BEGIN;
DROP TABLE IF EXISTS _src_osm_polygon_waterbody;
COMMIT;

BEGIN;
CREATE TABLE _src_osm_polygon_waterbody AS
SELECT
	"osm_id",
	"name",
	ST_Multi(ST_MakeValid("way")) AS "way"
FROM
	_src_osm_polygon op
WHERE
	op.water IN ('pond', 'lake', 'reservoir', 'oxbow', 'lock', 'cove', 'lagoon', 'marina')
AND
	op.name IS NOT NULL
AND 
	ST_Area("way") > 20.0;
COMMIT;

BEGIN;
INSERT INTO
	place
	(place_class_id, place_centre_geom, place_geom, place_name)
SELECT
	CASE WHEN ST_Area("way") / 100000 > 3.0 THEN 13
	     ELSE 12
	     END AS place_class_id,
	ST_Centroid("way") AS place_centre_geom,
	"way" AS place_geom,
	"name" AS place_name
FROM
	_src_osm_polygon_waterbody;
COMMIT;

BEGIN;
DROP TABLE IF EXISTS _src_osm_polygon_waterbody;
COMMIT;
