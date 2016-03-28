DROP TABLE IF EXISTS
	_src_os_oproad_road_missing;

CREATE TABLE
	_src_os_oproad_road_missing
AS SELECT
	CASE WHEN o.class = 'Motorway' THEN 1
	     WHEN o.strategic = 'Trunk' THEN 2
	     WHEN o.class = 'A Road' THEN 3
	     WHEN o.class = 'B Road' THEN 4
	     WHEN o.class = 'Unclassified' THEN 6
	     WHEN o.class = 'Not Classified' THEN 7
	END as edge_class_id,
	CASE WHEN o.class = 'Pedestrianised Street' THEN 7
	     ELSE 1
	END as edge_access_id,
	CASE WHEN o.name1 IS NULL THEN o.roadnumber
	     WHEN o.name1 IS NOT NULL AND o.roadnumber IS NOT NULL THEN o.name1 || ' (' || o.roadnumber || ')'
	     ELSE o.name1 
	END AS edge_name,
	ST_SetSRID(o.geom, 27700) as edge_geom,
	CASE WHEN o.structure = 'Bridge' THEN 1
	     WHEN o.structure = 'Tunnel' THEN -1
	     ELSE 0
	END as edge_level,
	CASE WHEN o.structure = 'Bridge' THEN true
	     ELSE false
	END as edge_bridge,
	CASE WHEN o.structure = 'Tunnel' THEN true
	     ELSE false
	END as edge_tunnel,
	o.gid as edge_source_id,
	CASE WHEN o.formofway = 'Slip Road' THEN true
	     ELSE false
	END as edge_oneway,
	CASE 
		WHEN o.formofway = 'Roundabout' THEN true
		ELSE false
	END as edge_roundabout,
	CASE WHEN o.formofway = 'Slip Road' THEN true
	     ELSE false
	END as edge_slip
FROM
	_src_os_oproad_road o
LEFT JOIN
	edge_oproad_matching m
ON
	o.gid = m.oproad_id
WHERE
	m.oproad_id IS NULL 
AND
	length >= 5.0
AND
	o.fictitious = 'false';

SELECT Populate_Geometry_Columns('_src_os_oproad_road_missing'::regclass);

-- Add the new edges to the main edge table
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
FROM
	_src_os_oproad_road_missing;

DROP TABLE IF EXISTS
	_src_os_oproad_road_missing;
