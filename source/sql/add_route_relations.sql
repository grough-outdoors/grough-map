TRUNCATE TABLE edge_route;

-- Relate existing edges to routes
INSERT INTO
	edge_route
	(relation_edge_id, relation_route_id)
SELECT DISTINCT ON (e.edge_id, r.route_id)
	e.edge_id,
	r.route_id
FROM
	edge e
INNER JOIN
	_tmp_route_segments r
ON
	e.edge_geom && r.route_geom
AND
	ST_Within(r.route_geom, e.edge_geom);

DROP TABLE IF EXISTS _tmp_routes;
DROP TABLE IF EXISTS _tmp_route_segments;
