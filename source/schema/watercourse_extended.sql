CREATE OR REPLACE VIEW watercourse_extended AS
SELECT
	w.watercourse_id,
	w.watercourse_class_id,
	w.watercourse_width,
	w.watercourse_geom,
	w.watercourse_name,
	c.class_name,
	c.class_draw_order,
	c.class_draw_line
FROM
	watercourse w
LEFT JOIN
	watercourse_classes c
ON
	c.class_id = w.watercourse_class_id
ORDER BY
	c.class_draw_order ASC,
	w.watercourse_width DESC;
	
ALTER TABLE watercourse_extended OWNER TO "grough-map";
SELECT Populate_Geometry_Columns('watercourse_extended'::regclass);
