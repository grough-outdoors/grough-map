TRUNCATE
	area;

-- *************************************
-- Import airports
-- *************************************
INSERT INTO area
	(
		area_geom,
		area_name,
		area_class_id
	)
SELECT
	way,
	name,
	37	-- Airport
FROM
	dblink('dbname=osm hostaddr=127.0.0.1 user=luke password=umd2048196',
'SELECT 
	a.way,
	a.name
 FROM planet_osm_polygon a 
 WHERE a.aeroway IN (''aerodrome'');')
	AS t1(
		  way geometry(Geometry,27700),
		  name text
	);
