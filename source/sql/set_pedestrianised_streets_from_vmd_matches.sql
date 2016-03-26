UPDATE
	edge
SET
	edge_access_id = 7,
	edge_class_id = 1
FROM
(
	SELECT
		edge_id
	FROM
		edge e
	INNER JOIN
		_import_vmd_osm_matches m
	ON
		e.edge_source_id = m.osm_id
	LEFT JOIN
		import_vmd_roads v
	ON
		v.gid = m.vmd_id
	WHERE
		v.classifica = 'Pedestrianised Street'
) AS SQ
WHERE
	SQ.edge_id = edge.edge_id;