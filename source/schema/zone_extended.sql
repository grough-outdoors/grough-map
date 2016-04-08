CREATE OR REPLACE VIEW zone_extended AS
SELECT
	z.zone_id,
	z.zone_class_id,
	z.zone_geom,
	c.class_name
FROM
	zone z
LEFT JOIN
	zone_classes c
ON
	c.class_id = z.zone_class_id
ORDER BY
	c.class_draw_order ASC;
	
ALTER TABLE zone_extended OWNER TO "grough-map";
SELECT Populate_Geometry_Columns('zone_extended'::regclass);
