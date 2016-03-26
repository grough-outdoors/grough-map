--DROP TABLE IF EXISTS
--	raw_vmd_water_coarse;

--CREATE TABLE
--	raw_vmd_water_coarse
--AS SELECT
--	gid,
--	value,
--	ST_SimplifyPreserveTopology( ST_MakeValid( ST_Simplify( geom, 10.0 ) ), 0.1 ) AS geom
--FROM
--	_import_vmd_water;

--DELETE FROM
--	raw_vmd_water_coarse
--WHERE
--	ST_GeometryType(geom) = 'ST_GeometryCollection';

--CREATE INDEX "Idx: raw_vmd_water_coarse::geom"
--  ON public.raw_vmd_water_coarse
--  USING gist
--  (geom);
--ALTER TABLE public.raw_vmd_water_coarse CLUSTER ON "Idx: raw_vmd_water_coarse::geom";

DROP TABLE IF EXISTS
	watercourses;

CREATE TABLE
	watercourses
AS 
SELECT
	e.edge_gid AS wc_src_os_gid,
	e.name AS wc_name_os,
	e.form AS wc_form,
	e.line AS wc_line,
	CASE WHEN COUNT(e.outline) = 0 THEN 1.0
	ELSE
		Min( 
			ST_Distance( 
				ST_Line_Interpolate_Point( e.line, e.i ),
				ST_ClosestPoint( 
					ST_ExteriorRing( e.outline ), 
					ST_Line_Interpolate_Point( e.line, i )
				)
			) * 2.0
		) 
	END AS wc_width
FROM
(
	SELECT
		em."gid" AS edge_gid,
		"name",
		"form",
		"i",
		(ST_Dump(em."geom")).geom AS line,
		CASE WHEN ST_NumGeometries(w.geom) > 1
		     THEN ST_GeometryN(w.geom, generate_series(1, ST_NumGeometries(w.geom))) 
		     ELSE w.geom
		END AS outline
	FROM
		raw_oswater_edges as em
	LEFT JOIN
		( SELECT generate_series( 0, 10, 2 )::double precision / 10 AS i ) AS i
	ON
		gid IS NOT NULL
	LEFT JOIN
		raw_vmd_water_coarse w
	ON
		w.geom && em.geom
	AND 
		ST_Intersects( em.geom, w.geom )
) AS e
WHERE
	ST_Intersects( e.line, e.outline )
OR
	e.outline IS NULL
GROUP BY
	edge_gid, e.name, e.form, e.line;
	