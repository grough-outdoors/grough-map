﻿CREATE OR REPLACE VIEW edge_label AS
SELECT
	e.edge_id,
	e.edge_class_id,
	e.edge_access_id,
	CASE WHEN c.class_name NOT IN ('Motorway', 'A road', 'B road', 'Trunk road')
		THEN 
			CASE WHEN trim(e.edge_name) SIMILAR TO '([A-Z0-9]+[0-9]+|[0-9]+)' THEN null
			     ELSE regexp_replace(e.edge_name, '\([^\(]+\)$', '', 'g')::character varying
			END
		ELSE e.edge_name
	END AS edge_name,
	CASE WHEN c.class_name IN ('Motorway', 'A road', 'B road', 'Trunk road')
		THEN regexp_replace(e.edge_name, '(^[^\(]+\(|\)$)', '', 'g')::character varying
		ELSE 
			CASE WHEN trim(e.edge_name) SIMILAR TO '([A-Z0-9]+[0-9]+|[0-9]+)' THEN null
			     ELSE regexp_replace(e.edge_name, '\([^\(]+\)$', '', 'g')::character varying
			END
	END AS edge_name_short,
	--e.edge_geom,
	e.edge_level + e.edge_bridge::integer AS edge_level,
	e.edge_bridge,
	e.edge_tunnel,
	e.edge_source_id,
	e.edge_oneway,
	e.edge_roundabout,
	e.edge_slip,
	c.class_name,
	a.access_name
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
WHERE
	class_label = true
AND
	edge_slip = false
AND
	edge_roundabout = false
AND
	(ST_Length(edge_geom) > 500.0 OR char_length(regexp_replace(edge_name, '(^[^\(]+\(|\)$)', '', 'g')) < 5)
AND
	-- We label railway bridges, and railway 'lines', but not railway tunnels (not drawn)
	NOT ( class_name IN ('Railway', 'Other railway') AND ( edge_tunnel = true OR lower(edge_name) NOT LIKE '%line%' ) )
ORDER BY
	e.edge_level DESC, 
	c.class_draw_order DESC,
	e.edge_bridge DESC;
	
ALTER TABLE edge_label OWNER TO "grough-map";
SELECT Populate_Geometry_Columns('edge_label'::regclass);