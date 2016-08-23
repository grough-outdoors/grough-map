CREATE OR REPLACE VIEW route_extended AS
SELECT
	e.*,
	r.route_name,
	r.route_ref,
	c.*,
	ec.class_name AS edge_class_name,
	ea.access_name as edge_access_name
FROM
	edge e
INNER JOIN
	edge_route er
ON
	er.relation_edge_id = e.edge_id
INNER JOIN
	edge_classes ec
ON
	e.edge_class_id = ec.class_id
INNER JOIN
	edge_access ea
ON
	e.edge_access_id = ea.access_id
INNER JOIN
	route r
ON
	r.route_id = er.relation_route_id
INNER JOIN
	route_classes c
ON
	r.route_class_id = c.class_id;

ALTER TABLE route_extended OWNER TO "grough-map";
SELECT Populate_Geometry_Columns('route_extended'::regclass);
