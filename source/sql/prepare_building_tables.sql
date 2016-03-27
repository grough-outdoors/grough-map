DROP TABLE IF EXISTS
	_src_osm_polygon_building;

CREATE TABLE
	_src_osm_polygon_building
AS SELECT
	*
FROM
	_src_osm_polygon
WHERE
	building IS NOT NULL
AND
	ST_GeometryType(way) = 'ST_Polygon';
	
ALTER TABLE _src_osm_polygon_building
	ALTER COLUMN way 
	TYPE geometry(MultiPolygon, 27700) USING ST_Multi(way);

UPDATE
	_src_osm_polygon_building
SET
	way=ST_MakeValid(ST_Simplify(way, 1.2));

CREATE INDEX "Idx: _src_osm_polygon_building::way"
  ON _src_osm_polygon_building
  USING gist
  (way);
ALTER TABLE _src_osm_polygon_building
  CLUSTER ON "Idx: _src_osm_polygon_building::way";

UPDATE
	_src_os_opmplc_building
SET
	geom=ST_Simplify(geom, 1.2);

CREATE INDEX "Idx: _src_os_opmplc_building::geom"
  ON _src_os_opmplc_building
  USING gist
  (geom);
ALTER TABLE _src_os_opmplc_building
  CLUSTER ON "Idx: _src_os_opmplc_building::geom";

SELECT populate_geometry_columns('_src_osm_polygon_building'::regclass); 
