-- Convert any existing legal footpaths in coverage areas to be of unknown status
UPDATE
	edge E
SET
	edge_access_id = 3
FROM
(
	SELECT
		e.edge_id
	FROM
		raw_prow_authorities a
	LEFT JOIN
		edge e
	ON
		e.edge_geom && a.geom_full
	AND
		ST_Within(e.edge_geom, a.geom_small)
	WHERE
		a.prow_status = 'Full coverage'
	AND
		e.edge_class_id IN (9, 10, 11) -- Ford, path, steps
	AND
		e.edge_access_id = 4
) SA
WHERE SA.edge_id = E.edge_id;

-- Set matched edges to use their legal status from the official PRoW datasets
UPDATE
	edge E
SET
	edge_access_id = 
	CASE WHEN type='Public footpath' THEN 4
	     WHEN type='Bridleway' THEN 8
	     WHEN type='Byway open to all traffic' THEN 6
	     WHEN type='Restricted byway' THEN 10
	     WHEN type='Permissive path' THEN 5
	END
FROM
(
	SELECT
		m.prow_id,
		p.type,
		m.edge_id
	FROM
		raw_prow p
	LEFT JOIN
		edge_prow_matching m
	ON
		p.id = m.prow_id
	GROUP BY
		m.prow_id, m.edge_id, p.type
	HAVING
		p.type IS NOT NULL
) SA
WHERE 
	SA.edge_id = E.edge_id;

-- Build a list of new edges to be added
DROP TABLE IF EXISTS
	edge_prow_additions;

CREATE TABLE
	edge_prow_additions
AS SELECT
	CASE WHEN type='Public footpath' THEN 17
	     WHEN type='Bridleway' THEN 8
	     WHEN type='Byway open to all traffic' THEN 8
	     WHEN type='Restricted byway' THEN 8
	     WHEN type='Permissive path' THEN 8
	END AS edge_class_id,
	CASE WHEN type='Public footpath' THEN 4
	     WHEN type='Bridleway' THEN 8
	     WHEN type='Byway open to all traffic' THEN 6
	     WHEN type='Restricted byway' THEN 10
	     WHEN type='Permissive path' THEN 5
	END AS edge_access_id,
	NULL::character varying AS edge_name,
	(ST_Dump(ST_Multi(ST_CollectionExtract(
	CASE WHEN match_prow IS NULL OR ST_IsEmpty(match_prow)
		THEN base_prow
		ELSE ST_Intersection(
			base_prow,
			ST_MakeValid(ST_SymDifference(
				ST_MakeValid(ST_Buffer(base_prow, 0.5, 'endcap=flat join=round')), 
				ST_MakeValid(ST_Buffer(match_prow, 0.5, 'endcap=flat join=round'))
			))
		)
	END 
	, 2)))).geom AS edge_geom,
	0::integer AS edge_level,
	false AS edge_bridge,
	false AS edge_tunnel,
	id AS edge_source_id,
	false AS edge_oneway,
	false AS edge_roundabout,
	false AS edge_slip
FROM
(
	SELECT
		p.id,
		p.type,
		p.geom AS base_prow,
		ST_CollectionExtract(ST_Collect(m.geom_edge), 2) AS match_edge,
		ST_CollectionExtract(ST_Collect(m.geom_prow), 2) AS match_prow
	FROM
		raw_prow p
	LEFT JOIN
		edge_prow_matching m
	ON
		p.id = m.prow_id
	GROUP BY
		p.id, p.geom, p.type
	HAVING
		p.type IS NOT NULL
) AS SA;

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
	edge_prow_additions;

SELECT Populate_Geometry_Columns('edge_prow_additions'::regclass);