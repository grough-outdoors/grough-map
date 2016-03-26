CREATE OR REPLACE VIEW public.edge_statistics AS
SELECT
	c.class_name || ' - ' || a.access_name AS edge_type,
	Sum(ST_Length(e.edge_geom))/1000 AS edge_length_km
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
GROUP BY
	c.class_name || ' - ' || a.access_name
ORDER BY
	Sum(ST_Length(e.edge_geom)) DESC;
	
ALTER TABLE public.edge_statistics OWNER TO "grough-map";
