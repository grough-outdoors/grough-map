BEGIN;
DROP TABLE IF EXISTS _tmp_surface_coarse;
DROP TABLE IF EXISTS _tmp_surface_water;
COMMIT;

-- Get surfaces
BEGIN;
CREATE TABLE
	_tmp_surface_water
AS SELECT
	surface_id,
	ST_Multi(ST_CollectionExtract(ST_MakeValid(ST_Simplify(surface_geom, 20.0)), 3)) AS surface_geom
FROM
(
	SELECT
		surface_id,
		surface_geom
	FROM
		surface s
	WHERE
		surface_class_id IN (5, 6)
) SA;
COMMIT;

BEGIN;
CREATE INDEX "Idx: _tmp_surface_water::surface_geom"
  ON _tmp_surface_water
  USING gist
  (surface_geom);
ALTER TABLE _tmp_surface_water CLUSTER ON "Idx: _tmp_surface_water::surface_geom";
COMMIT;

-- Remove foreshore from tidal water
BEGIN;
UPDATE 
	_tmp_surface_water U
SET
	surface_geom = N.surface_geom
FROM
(
	SELECT
		c.surface_id,
		ST_Multi(ST_CollectionExtract(ST_Multi(ST_Difference(first(c.surface_geom), ST_Buffer(ST_Simplify(ST_Collect(s.surface_geom), 10.0), 15.0))), 3)) AS surface_geom
	FROM
		surface a
	INNER JOIN
		_tmp_surface_water c
	ON
		a.surface_id = c.surface_id
	INNER JOIN
		surface s
	ON
		s.surface_class_id IN (1)
	AND
		c.surface_geom && s.surface_geom
	WHERE
		a.surface_class_id = 5
	GROUP BY
		c.surface_id
	HAVING
		Count(s.surface_id) > 0
) N
WHERE
	U.surface_id = N.surface_id;
COMMIT;

-- Create base
BEGIN;
CREATE TABLE
	_tmp_surface_coarse
AS SELECT
	watercourse_id,
	ST_Multi(ST_CollectionExtract(ST_Union(surface_geom), 3)) AS surface_geom,
	ST_Simplify(first(w.watercourse_geom), 10) AS watercourse_geom
FROM
	watercourse w, _tmp_surface_water s
WHERE
	s.surface_geom && w.watercourse_geom
AND
	w.watercourse_class_id IN (1, 3, 4, 5, 6)
AND
	ST_Intersects(s.surface_geom, w.watercourse_geom)
GROUP BY
	watercourse_id;

SELECT populate_geometry_columns('_tmp_surface_water'::regclass); 
SELECT populate_geometry_columns('_tmp_surface_coarse'::regclass); 
COMMIT;

-- Get rid of small rivers	
DELETE FROM
	_tmp_surface_coarse
WHERE
	watercourse_id 
IN
(
	SELECT
		watercourse_id
	FROM
		_tmp_surface_coarse
	WHERE
		ST_Area(ST_MakeValid(ST_Buffer(ST_Simplify(surface_geom, 40.0), -40.0))) = 0.0
);

-- Get subsets of lines
BEGIN;
UPDATE
	_tmp_surface_coarse
SET
	watercourse_geom = ST_Multi(ST_CollectionExtract(ST_Intersection(surface_geom, watercourse_geom), 2));
COMMIT;
