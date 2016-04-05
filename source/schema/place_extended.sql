CREATE OR REPLACE VIEW place_extended AS
SELECT
	p.place_id,
	p.place_name,
	p.place_class_id,
	p.place_centre_geom,
	p.place_geom,
	c.class_name
FROM
	place p
LEFT JOIN
	place_classes c
ON
	c.class_id = p.place_class_id
ORDER BY
	c.class_draw_order ASC,
	ST_Area(place_geom) DESC;
	
ALTER TABLE place_extended OWNER TO "grough-map";
SELECT Populate_Geometry_Columns('place_extended'::regclass);
