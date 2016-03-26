INSERT INTO
	edge
	(
		edge_class_id,
		edge_access_id,
		edge_name,
		edge_geom,
		edge_level,
		edge_bridge,
		edge_tunnel,
		edge_source_id,
		edge_oneway,
		edge_roundabout,
		edge_slip
	)
SELECT
	m.class_id AS edge_class_id,
	a.access_id AS edge_access_id,
	name AS edge_name,
	way AS edge_geom,
	CASE WHEN layer IS NULL THEN 0::integer
	     ELSE convert_to_integer(layer)
	     END AS edge_level,
	CASE WHEN o.bridge IN ('yes', 'swing', 'clapper', 'footbridge', 'humpback', 'viaduct', 'aqueduct', 'suspension', 'true', 'arch', 'boardwalk', 'cable-stayed', 'lift', 'sleepers') THEN true
	     ELSE false
	     END AS edge_bridge,
	CASE WHEN o.tunnel IN ('yes', 'cut_and_cover', 'footpath', 'culvert', 'building_passage', 'underpass', 'box_jack') THEN true
	     ELSE false
	     END AS edge_tunnel,
	osm_id AS edge_source_id,
	CASE WHEN o.oneway IN ('yes', 'true', '1') THEN true
	     ELSE false
	     END AS edge_oneway,
	false AS edge_roundabout,
	false AS edge_slip
FROM
	import_osm_railways o
INNER JOIN
	_import_osm_railway_to_class m
ON
	o.railway = m.railway
INNER JOIN
	edge_classes c
ON
	m.class_id = c.class_id
LEFT JOIN
	edge_access a
ON
	a.access_id = c.class_default_access_id;

-- There are lots of railways which have the wrong levels
-- set sadly... this isn't a true fix but it improves things
UPDATE
	edge
SET
	edge_level = -1
WHERE
	( edge_level IS NULL OR edge_level = 0 )
AND
	edge_class_id IN ( 15, 16, 17, 18 )
AND
	edge_bridge = false;
