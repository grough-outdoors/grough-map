SELECT
	ST_Length(geom_oproad) AS geom_oproad_length,
	ST_Length(geom_edge) AS geom_edge_length,
	Abs(ST_Length(geom_oproad) - ST_Length(geom_edge)) AS geom_diff_length,
	ST_AsText(ST_StartPoint(geom_oproad)) AS geom_oproad_start,
	*
FROM (
	SELECT
		m.*
	FROM (
		SELECT
			m.edge_id,
			Min(m.hausdorff) AS hausdorff
		FROM ( 
			SELECT * FROM edge_oproad_matching 
			WHERE geom_oproad && ST_SetSRID(ST_MakeBox2D(ST_Point( 400000, 400000 ), ST_Point( 500000, 500000 )), 27700)
		     ) m
		GROUP BY
			m.edge_id
	) SA
	LEFT JOIN
		edge_oproad_matching m
	ON
		m.edge_id = SA.edge_id
	AND
		m.hausdorff = SA.hausdorff
) m
LEFT JOIN
	_src_os_oproad_road o
ON
	m.oproad_id = o.gid
LEFT JOIN
	edge e
ON
	m.edge_id = e.edge_id
WHERE
	e.edge_class_id = 8
AND
	ST_Length(e.edge_geom) > 40.0
AND
	ST_Length(m.geom_edge) > 40.0
AND
	o.class IN ('A Road', 'B Road', 'Motorway', 'Unclassified')
ORDER BY 
	o.class
LIMIT
	5000;