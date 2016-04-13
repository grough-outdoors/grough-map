BEGIN;
DROP TABLE IF EXISTS _tmp_surface_coarse;

-- Create base
CREATE TABLE
	_tmp_surface_coarse
AS SELECT
	watercourse_id,
	ST_Multi(ST_CollectionExtract(ST_Collect(surface_geom), 3)) AS surface_geom,
	ST_Simplify(w.watercourse_geom, 10) AS watercourse_geom
FROM
	watercourse w
LEFT JOIN
	surface s
ON
	s.surface_geom && w.watercourse_geom
AND
	ST_Intersects(s.surface_geom, w.watercourse_geom)
WHERE
	w.watercourse_class_id IN (1, 3, 4, 5, 6)
AND
	s.surface_class_id IN (5, 6)
GROUP BY
	watercourse_id, watercourse_geom;

SELECT populate_geometry_columns('_tmp_surface_coarse'::regclass); 
COMMIT;

-- Generalise and clean
BEGIN;
UPDATE
	_tmp_surface_coarse
SET
	surface_geom = ST_Multi(ST_CollectionExtract(ST_MakeValid(ST_Simplify(surface_geom, 20.0)), 3));
COMMIT;

-- Get subsets of lines
BEGIN;
UPDATE
	_tmp_surface_coarse
SET
	watercourse_geom = ST_Multi(ST_CollectionExtract(ST_Intersection(surface_geom, watercourse_geom), 2));
COMMIT;
	
-- Update widths
BEGIN;
UPDATE
	watercourse
SET
	watercourse_width = SC.watercourse_avg_distance
FROM (
	SELECT
		watercourse_id,
		Avg(watercourse_distance) AS watercourse_avg_distance,
		Min(watercourse_distance) AS watercourse_min_distance
	FROM
	(
		SELECT
			watercourse_id,
			greatest(1, ST_Distance( SA.watercourse_point, ST_Boundary(SA.surface_geom) )) AS watercourse_distance
		FROM
		(
			SELECT
				watercourse_id,
				ST_Line_Interpolate_Point((ST_Dump(watercourse_geom)).geom, z::numeric / 100) AS watercourse_point,
				surface_geom
			FROM
				_tmp_surface_coarse
			LEFT JOIN 
				generate_series(0, 100, 10) AS z
			ON 
				true
		) SA
	) SB
	GROUP BY
		watercourse_id
) SC
WHERE
	SC.watercourse_id = watercourse.watercourse_id;
COMMIT;

BEGIN;
DROP TABLE _tmp_surface_coarse;
COMMIT;

