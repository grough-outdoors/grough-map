INSERT INTO
	edge
	( edge_name, edge_class_id, edge_access_id, edge_geom )
SELECT
	CASE WHEN vmd.name IS NOT NULL AND vmd.dftnumber IS NOT NULL THEN CONCAT(vmd.name, ' (', vmd.dftnumber, ')')
	     WHEN vmd.name IS NOT NULL AND vmd.dftnumber IS NULL THEN vmd.name
	     WHEN vmd.name IS NULL AND vmd.dftnumber IS NOT NULL THEN vmd.dftnumber
	     ELSE NULL
	     END AS edge_name,
	cla.class_id AS edge_class_id,
	acc.access_id AS edge_access_id,
	vmd.geom AS edge_geom
FROM
	import_vmd_roads vmd
LEFT JOIN
	edge_classes cla
ON
	(regexp_split_to_array(vmd.classifica, ','))[1] = cla.class_name OR
	( vmd.classifica = 'Pedestrianised Street' AND cla.class_name = 'Local Street' ) OR
	( vmd.classifica = 'Private Road Publicly Accessible' AND cla.class_name = 'Local Street' )
LEFT JOIN
	edge_access acc
ON
	acc.access_id = CASE WHEN vmd.classifica = 'Pedestrianised Street' THEN 7
			     WHEN vmd.classifica = 'Private Road Publicly Accessible' THEN 9
			     ELSE cla.class_default_access_id
			END;
