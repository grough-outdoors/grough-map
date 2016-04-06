DROP INDEX IF EXISTS 
	"Idx: _src_os_vmdvec_ornament::geom";

CREATE INDEX 
	"Idx: _src_os_vmdvec_ornament::geom"
ON 
	_src_os_vmdvec_ornament
USING 
	gist (geom);
	
ALTER TABLE 
	_src_os_vmdvec_ornament 
CLUSTER ON 
	"Idx: _src_os_vmdvec_ornament::geom";

INSERT INTO 
	surface 
	(surface_geom, surface_class_id)
SELECT
	ST_Collect(ST_Simplify(o.geom, 1.2)) AS surface_geom,
	3 AS surface_class_id
FROM
(
	SELECT
		ST_SetSRID( 
			ST_MakeBox2D(
				ST_Point( ST_XMin( tile_geom ) + subgrid_east       , ST_YMin( tile_geom ) + subgrid_north ),
				ST_Point( ST_XMin( tile_geom ) + subgrid_east + 1000, ST_YMin( tile_geom ) + subgrid_north + 1000 )
			),
		27700 ) AS tile_geom
	FROM
		grid g
	LEFT JOIN 
		generate_series(0,9000,1000) AS subgrid_east ON true 
	LEFT JOIN 
		generate_series(0,9000,1000) AS subgrid_north ON true
) g
LEFT JOIN
	_src_os_vmdvec_ornament o
ON
	g.tile_geom && o.geom
GROUP BY
	g.tile_geom;

DROP INDEX IF EXISTS 
	"Idx: _src_os_vmdvec_ornament::geom";
