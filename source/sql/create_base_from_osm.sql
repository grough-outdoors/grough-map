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
	OR ( o.__COLUMNNAME__ = 'construction' AND ( o.construction = m.__COLUMNNAME__ OR (o.construction IS NULL AND m.__COLUMNNAME__ = 'road') ) )
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
	CASE WHEN o.__COLUMNNAME__ = 'construction' THEN 13 			-- Under construction (no access)
		 WHEN c.class_name IN ('Path', 'Steps') THEN 			-- Footpaths, bridleways
	          CASE WHEN o.highway IN ('cycleway') THEN 8				-- Cycle path (bridleway)
		       WHEN o.bicycle IN ('yes', 'designated') 				-- Legal bridleway
		         OR o.highway IN ('bridleway') 
		         OR o.designation = 'bridleway'
		         OR o.designation LIKE '%public_bridleway%'
		         OR ((o.ncn IS NOT NULL OR o.ncn_ref IS NOT NULL OR o.route = 'ncn' OR o.network = 'ncn') AND o.ncn != 'proposed' AND o.state != 'proposed') 
		         OR ((o.rcn IS NOT NULL OR o.rcn_ref IS NOT NULL OR o.route = 'rcn' OR o.network = 'rcn') AND o.rcn != 'proposed' AND o.state != 'proposed')
		         OR ((o.lcn IS NOT NULL OR o.lcn_ref IS NOT NULL OR o.route = 'lcn' OR o.network = 'lcn') AND o.lcn != 'proposed' AND o.state != 'proposed')  
		       THEN 8
	               WHEN o.access IN ('yes', 'designated') 				-- Legal public footpath
	                 OR o.highway IN ('footway') 
	                 OR o.foot IN ('yes', 'designated')
		         OR o.designation LIKE '%public_footpath%'
		         OR o.designation = 'core_path' 
		         OR o.route IN ('hiking', 'foot')
		         OR o.network IN ('nwn', 'rwn', 'lcn')
		       THEN 4
		       WHEN o.access IN ('permissive', 'customers') 			-- Private permissive path
		         OR o.foot IN ('permissive', 'customers')
		         OR o.designation = 'permissive_footpath'
		         OR o.designation LIKE '%permissive_footpath%' 
		       THEN 5	
		       WHEN o.access IN ('no', 'private') 				-- Private restricted use path
		         OR o.foot IN ('no', 'private') 
		       THEN 11 
	               ELSE 3 								-- Default footpath of some description
	          END
	      WHEN c.class_name IN ('Track', 'Service road') THEN 		-- Tracks and bridleways
	          CASE WHEN o.access IN ('no') THEN 2					-- No access track
	               WHEN o.highway IN ('service', 'services', 'depot', 		-- Private access roads
	                                  'construction_route', 'access') 
	               THEN 2
	               WHEN o.highway IN ('bridleway')					-- Explicit bridleway
	                 OR o.designation = 'bridleway'
		         OR o.designation LIKE '%public_bridleway%' 
		         OR ((o.ncn IS NOT NULL OR o.ncn_ref IS NOT NULL OR o.route = 'ncn' OR o.network = 'ncn') AND o.ncn != 'proposed' AND o.state != 'proposed') 
		         OR ((o.rcn IS NOT NULL OR o.rcn_ref IS NOT NULL OR o.route = 'rcn' OR o.network = 'rcn') AND o.rcn != 'proposed' AND o.state != 'proposed')
		         OR ((o.lcn IS NOT NULL OR o.lcn_ref IS NOT NULL OR o.route = 'lcn' OR o.network = 'lcn') AND o.lcn != 'proposed' AND o.state != 'proposed')  
		       THEN 8
	               WHEN ( o.bicycle IN ('yes', 'designated') 			-- Byway open to all traffic
	                      OR o.horse IN ('yes', 'designated') 
	                      OR o.highway = 'cycleway' ) 
	                 AND o.motorcar IN ('yes', 'designated', 'discouraged') 
	                 AND o.highway  = 'byway'
	                 OR o.designation LIKE '%byway_open_to_all_traffic%' 
	               THEN 6 
	               WHEN ( o.bicycle IN ('yes', 'designated') 			-- Legal bridleway OR restricted byway.. don't know which
	                      OR o.horse IN ('yes', 'designated') 
	                      OR o.highway = 'cycleway' ) 
	                 AND ( o.motorcar IN ('permissive', 'private', 'no') 
	                      OR o.motorcar IS NULL ) 
	                 AND o.highway  = 'byway'
	                 OR o.designation LIKE '%restricted_byway%' 
	               THEN 10 
	               WHEN ( o.bicycle IN ('yes', 'designated') 			-- Legal bridleway OR restricted byway.. don't know which
	                      OR o.horse IN ('yes', 'designated') 
	                      OR o.highway = 'cycleway' ) 
	                 AND ( o.motorcar IN ('permissive', 'private', 'no') 
	                      OR o.motorcar IS NULL ) 
	                 AND o.highway != 'byway' 
	               THEN 8 								-- Legal public footpath
	               WHEN o.foot IN ('yes', 'designated') 
	                 AND ( o.bicycle IN ('no', 'dismount') 
	                      OR o.bicycle IS NULL ) 
		         OR o.route IN ('hiking', 'foot')
		         OR o.network IN ('nwn', 'rwn', 'lcn')
	               THEN 4
	               ELSE 12
	          END
	      WHEN c.class_name IN ('Local street', 'Motorway', 'Minor road', 	-- Proper roads
	                            'B road', 'A road', 'Trunk road', 
	                            'Service road', 'Parking') THEN  
	          CASE WHEN o.access IN ('no', 'emergency', 'controlled') THEN 2	-- Private road
		       WHEN o.motorcar IN ('no') or o.highway IN ('pedestrian') THEN 7	-- Pedestrianised
	               WHEN o.highway IN ('access') THEN 2				-- Private road
	               ELSE c.class_default_access_id
	          END
	     ELSE c.class_default_access_id
	END;