CREATE OR REPLACE VIEW feature_symbol AS
SELECT
	f.feature_id,
	f.feature_class_id,
	f.feature_geom,
	c.class_name,
	c.class_draw_order,
	c.class_subsurface,
	c.class_surface,
	c.class_overhead,
	c.class_plural_name,
	c.class_radius,
	c.class_label,
	c.class_label_rank
FROM
	feature_point f
LEFT JOIN
	feature_classes c
ON
	c.class_id = f.feature_class_id
WHERE
	c.class_symbolised = true
ORDER BY
	c.class_label_rank DESC;
	
ALTER TABLE feature_symbol OWNER TO "grough-map";
SELECT Populate_Geometry_Columns('feature_symbol'::regclass);
