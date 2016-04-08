CREATE OR REPLACE VIEW feature_linear_extended AS
SELECT
	f.feature_id,
	f.feature_class_id,
	f.feature_geom,
	c.class_name
FROM
	feature_linear f
LEFT JOIN
	feature_classes c
ON
	c.class_id = f.feature_class_id
ORDER BY
	c.class_draw_order ASC;
	
ALTER TABLE feature_linear_extended OWNER TO "grough-map";
SELECT Populate_Geometry_Columns('feature_linear_extended'::regclass);
