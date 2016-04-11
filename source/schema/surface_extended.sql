CREATE OR REPLACE VIEW surface_extended AS
SELECT
	s.surface_id,
	s.surface_class_id,
	s.surface_geom,
	c.class_name,
	c.class_below_zones
FROM
	surface s
LEFT JOIN
	surface_classes c
ON
	c.class_id = s.surface_class_id
ORDER BY
	c.class_draw_order ASC;
	
ALTER TABLE surface_extended OWNER TO "grough-map";
SELECT Populate_Geometry_Columns('surface_extended'::regclass);
