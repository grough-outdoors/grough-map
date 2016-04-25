CREATE OR REPLACE VIEW place_extended AS
SELECT
	p.place_id,
	p.place_name,
	p.place_class_id,
	p.place_centre_geom,
	p.place_geom,
	c.class_name,
	c.class_label,
	c.class_label_with_type,
	c.class_allow_text_scale,
	ST_Area(p.place_geom) / 1000000 AS place_square_km,
	c.class_draw_order
FROM
	place p
LEFT JOIN
	place_classes c
ON
	c.class_id = p.place_class_id
WHERE
	ST_Area(p.place_geom)/(1000*1000) >= c.class_label_min_km2
ORDER BY
	c.class_draw_order ASC,
	ST_Area(place_geom) DESC;
	
ALTER TABLE place_extended OWNER TO "grough-map";
SELECT Populate_Geometry_Columns('place_extended'::regclass);
