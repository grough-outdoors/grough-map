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
	grid g
LEFT JOIN
	_src_os_vmdvec_ornament o
ON
	g.tile_geom && o.geom
GROUP BY
	g.tile_name;

DROP INDEX IF EXISTS 
	"Idx: _src_os_vmdvec_ornament::geom";
