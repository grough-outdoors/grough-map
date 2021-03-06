﻿CREATE OR REPLACE VIEW feature_point_extended AS
SELECT
	f.feature_id,
	f.feature_class_id,
	f.feature_geom,
	c.class_name,
	c.class_draw_order,
	c.class_subsurface,
	c.class_surface,
	c.class_overhead,
	c.class_location_fixed
FROM
	feature_point f
LEFT JOIN
	feature_classes c
ON
	c.class_id = f.feature_class_id
ORDER BY
	c.class_draw_order ASC;
	
ALTER TABLE feature_point_extended OWNER TO "grough-map";
SELECT Populate_Geometry_Columns('feature_point_extended'::regclass);
