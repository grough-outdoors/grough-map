CREATE TABLE 
	_import_vmd_osm_matches
AS
SELECT
	osm_id,
	gid AS vmd_id,
	ST_HausdorffDistance( extract_edge, extract_osm ) AS match_hausdorff,
	ST_MaxDistance( extract_edge, extract_osm ) AS match_max_dist,
	ST_Distance( extract_edge, extract_osm ) AS match_min_dist,
	ST_Area( extract_area ) AS match_area
FROM
( 
	SELECT
		ST_Intersection( e.geom, ST_Intersection( ST_Buffer( o.way, 15.0, 'endcap=flat join=round' ), ST_Buffer( e.geom, 15.0, 'endcap=flat join=round' ) ) ) AS extract_edge,
		ST_Intersection( o.way, ST_Intersection( ST_Buffer( o.way, 15.0, 'endcap=flat join=round' ), ST_Buffer( e.geom, 15.0, 'endcap=flat join=round' ) ) ) AS extract_osm,
		ST_Intersection( ST_Buffer( o.way, 15.0, 'endcap=flat join=round' ), ST_Buffer( e.geom, 15.0, 'endcap=flat join=round' ) ) AS extract_area,
		*
	FROM
		import_osm_highways o
	LEFT JOIN
		import_vmd_roads e
	ON
		e.geom && ST_Buffer(o.way, 15.0)
	AND 
		o.highway IN (
			'Byway','motorway','access','motorway_link','living_street','residential',
			'yes','minor','primary','secondary','Residential','track','tertiary','trunk',
			'tertiary_link','secondary_link','unclassified','primary_link','byway','road',
			'unclassified','trunk_link','service','pedestrian'
		)
) AS A
WHERE
	ST_Area( extract_area ) >= 200.0 AND
	ST_HausdorffDistance( extract_edge, extract_osm ) <= 15.0 AND
	ST_Distance( extract_edge, extract_osm ) <= 15.0
	