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
	c.class_id AS edge_class_id,
	a.access_id AS edge_access_id,
	CASE WHEN o.name IS NULL THEN o.ref
	     WHEN o.name IS NOT NULL AND o.ref IS NOT NULL THEN o.name || ' (' || o.ref || ')'
	     ELSE o.name 
	     END AS edge_name,
	way AS edge_geom,
	CASE WHEN layer IS NULL THEN 0::integer
	     ELSE round(layer::numeric)::integer
	     END AS edge_level,
	CASE WHEN o.bridge IN ('yes', 'swing', 'clapper', 'footbridge', 'humpback', 'viaduct', 'gangway', 'ramp', 'rope', 'moveable', 'cantilever', 'suspension', 'true', 'arch', 'boardwalk', 'cable-stayed', 'lift', 'sleepers') THEN true
	     ELSE false
	     END AS edge_bridge,
	CASE WHEN o.tunnel IN ('yes', 'passage', 'asphalt', 'cut_and_cover', 'footpath', 'culvert', 'building_passage', 'underpass', 'box_jack') THEN true
	     ELSE false
	     END AS edge_tunnel,
	osm_id AS edge_source_id,
	CASE WHEN o.oneway IN ('yes', 'true', '1') THEN true
	     ELSE false
	     END AS edge_oneway,
	CASE WHEN o.junction IN ('roundabout', 'mini_roundabout') THEN true
	     ELSE false
	     END AS edge_roundabout,
	CASE WHEN o.highway LIKE '%_link' THEN true
	     ELSE false
	     END AS edge_slip
FROM
	_src_osm_line_transport o
INNER JOIN
	edge_import___COLUMNNAME__s m
ON
	o.__COLUMNNAME__ = m.__COLUMNNAME__
INNER JOIN
	edge_classes c
ON
	CASE WHEN '__COLUMNNAME__' = 'highway' AND o.highway = 'service' AND o.service = 'parking_aisle' THEN 14
	     ELSE m.class_id 
	END = c.class_id
LEFT JOIN
	edge_access a
ON
	a.access_id = 
	CASE WHEN c.class_name IN ('Path', 'Steps') THEN -- Footpath
	          CASE WHEN o.bicycle IN ('yes', 'designated') THEN 8									-- Legal bridleway
	               WHEN o.access IN ('yes', 'discouraged', 'designated') OR o.foot IN ('yes', 'discouraged', 'designated') THEN 4	-- Legal public footpath
		       WHEN o.access IN ('permissive', 'customers') OR o.foot IN ('permissive', 'customers') THEN 5			-- Private permissive path
		       WHEN o.access IN ('no', 'private') OR o.foot IN ('no', 'private') THEN 11					-- Private restricted use path
	               ELSE 11
	          END
	      WHEN c.class_name IN ('Track', 'Service road') THEN -- Tracks and bridleways
	          CASE WHEN o.access IN ('no') THEN 2											-- No access track
	               WHEN o.highway IN ('service', 'services', 'depot', 'construction_route', 'access') THEN 2			-- Private access roads
	               WHEN o.highway IN ('bridleway') THEN 2										-- Explicit bridleway
	               WHEN ( o.bicycle IN ('yes', 'designated') OR o.horse IN ('yes', 'designated') ) AND o.motorcar IN ('yes', 'designated', 'discouraged') AND o.highway  = 'byway' THEN 6 -- Byway open to all traffic
	               WHEN ( o.bicycle IN ('yes', 'designated') OR o.horse IN ('yes', 'designated') ) AND ( o.motorcar IN ('permissive', 'private', 'no') OR o.motorcar IS NULL ) AND o.highway  = 'byway' THEN 10 -- Legal bridleway OR restricted byway.. don't know which
	               WHEN ( o.bicycle IN ('yes', 'designated') OR o.horse IN ('yes', 'designated') ) AND ( o.motorcar IN ('permissive', 'private', 'no') OR o.motorcar IS NULL ) AND o.highway != 'byway' THEN 8 -- Legal bridleway OR restricted byway.. don't know which
	               WHEN o.foot IN ('yes', 'discouraged', 'designated') AND ( o.bicycle IN ('no', 'dismount') OR o.bicycle IS NULL ) THEN 4		-- Legal public footpath
	               WHEN o.highway IN ('cycleway') THEN 8							-- Cycle path (bridleway)
	               ELSE 12
	          END
	      WHEN c.class_name IN ('Local street', 'Motorway', 'Minor road', 'B road', 'A road', 'Trunk road', 'Service road', 'Parking') THEN  -- Proper roads
	          CASE WHEN o.access IN ('no', 'emergency', 'controlled') THEN 2							-- Private road
		       WHEN o.motorcar IN ('no') or o.highway IN ('pedestrian') THEN 7							-- Pedestrianised
	               WHEN o.highway IN ('access') THEN 2										-- Private road
	               ELSE c.class_default_access_id
	          END
	     ELSE c.class_default_access_id
	END;