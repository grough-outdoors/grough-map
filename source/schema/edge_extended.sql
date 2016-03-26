CREATE OR REPLACE VIEW edge_extended AS
SELECT
	e.edge_id,
	e.edge_class_id,
	e.edge_access_id,
	e.edge_name,
	e.edge_geom,
	e.edge_level + e.edge_bridge::integer AS edge_level,
	e.edge_bridge,
	e.edge_tunnel,
	e.edge_source_id,
	e.edge_oneway,
	e.edge_roundabout,
	c.class_name,
	a.access_name,
	c.class_name || ' - ' || a.access_name AS class_access_name
FROM
	edge e
LEFT JOIN
	edge_classes c
ON
	c.class_id = e.edge_class_id
LEFT JOIN
	edge_access a
ON
	a.access_id = e.edge_access_id
ORDER BY
	e.edge_level ASC, 
	e.edge_roundabout ASC,
	e.edge_slip DESC,
	c.class_draw_order ASC,
	e.edge_bridge ASC;
	
ALTER TABLE edge_extended OWNER TO "grough-map";
SELECT Populate_Geometry_Columns('edge_extended'::regclass);
