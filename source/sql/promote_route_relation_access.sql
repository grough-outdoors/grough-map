UPDATE
	edge
SET
	edge_access_id = Z.edge_new_access_id
FROM
(
	SELECT
		r.route_name,
		z.relation_edge_id,
		e.edge_access_id,
		CASE WHEN r.route_class_id IN (1,2) THEN 8
		     WHEN r.route_class_id IN (5) THEN 4
		     WHEN r.route_class_id IN (6) THEN 3
		END AS edge_new_access_id
	FROM
		edge_route z
	INNER JOIN
		route r
	ON
		z.relation_route_id = r.route_id
	INNER JOIN
		edge e
	ON
		e.edge_id = z.relation_edge_id
	WHERE
		r.route_class_id IN (1, 2, 5, 6)
	AND
	(
		( r.route_class_id IN (1, 2) AND e.edge_access_id IN (3, 4, 5, 12) )
	OR
		( r.route_class_id IN (5) AND e.edge_access_id IN (3, 12, 11, 5) )
	OR
		( r.route_class_id IN (6) AND e.edge_access_id IN (12, 11) )
	)
) Z
WHERE
	edge_id = Z.relation_edge_id;