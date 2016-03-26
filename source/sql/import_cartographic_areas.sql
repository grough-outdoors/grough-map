TRUNCATE
	cartographic_area;

-- *************************************
-- Import danger areas
-- *************************************
INSERT INTO cartographic_area
	(
		area_geom,
		area_class_id
	)
SELECT
	way,
	12	-- Danger area
FROM
	dblink('dbname=osm hostaddr=127.0.0.1 user=luke password=umd2048196',
'SELECT 
	a.way
 FROM planet_osm_polygon a 
 WHERE a.military IN (''danger_area'', ''range'');')
	AS t1(
		  way geometry(Geometry,27700)
	);

-- *************************************
-- Import walled areas
-- *************************************
INSERT INTO cartographic_area
	(
		area_geom,
		area_class_id
	)
SELECT
	way,
	32	-- Obstructing feature
FROM
	dblink('dbname=osm hostaddr=127.0.0.1 user=luke password=umd2048196',
'SELECT 
	CASE WHEN a.width IS NULL THEN a.way
	     ELSE ST_Buffer(ST_ExteriorRing( a.way ), 
		CASE WHEN (regexp_replace(a.width, ''[^0-9]*'' ,'''', ''g'')::double precision)/2 > 0.0 THEN
			  (regexp_replace(a.width, ''[^0-9]*'' ,'''', ''g'')::double precision)/2
		     ELSE 10.0
		END, ''endcap=flat join=round'') 
	END AS way
 FROM planet_osm_polygon a 
 WHERE a.barrier IN (''fence'', ''wall'', ''city_wall'', ''field'', ''garden_wall'', ''hedge'', ''wire_fence'', ''wood_fence'', ''field_boundary'');')
	AS t1(
		  way geometry(Geometry,27700)
	);

-- *************************************
-- Import airfield runway areas
-- *************************************
INSERT INTO cartographic_area
	(
		area_geom,
		area_class_id
	)
SELECT
	way,
	33	-- Runway
FROM
	dblink('dbname=osm hostaddr=127.0.0.1 user=luke password=umd2048196',
'SELECT 
	ST_Buffer(a.way, 
	CASE WHEN (regexp_replace(a.width, ''[^0-9]*'' ,'''', ''g'')::double precision)/2 > 0.0 THEN
		  (regexp_replace(a.width, ''[^0-9]*'' ,'''', ''g'')::double precision)/2
	     ELSE 10.0
	END, ''endcap=flat join=round'') AS way
 FROM planet_osm_line a 
 WHERE a.aeroway IN (''runway'', ''taxiway'');')
	AS t1(
		  way geometry(Geometry,27700)
	);
