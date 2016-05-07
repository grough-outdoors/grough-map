DROP TABLE IF EXISTS _tmp_surface_watercourses;

-- Fetch the widths for each surface water body
CREATE TABLE
	_tmp_surface_watercourses
AS SELECT
	s.surface_id,
	w.watercourse_id,
	w.watercourse_name,
	w.watercourse_width
FROM
	surface s
INNER JOIN
	watercourse w
ON
	w.watercourse_geom && s.surface_geom
AND
	ST_Intersects(w.watercourse_geom, s.surface_geom)
AND
	w.watercourse_class_id != 2
WHERE
	s.surface_class_id IN (5, 6);

-- Disable labelling on watercourses in lakes etc. if they're much thinner than
-- the others. Probably around islands and the extremities of the waterbody.
UPDATE
	watercourse w
SET
	watercourse_allow_linear_label = false
FROM
(
	SELECT
		w.watercourse_id
	FROM
		_tmp_surface_watercourses w
	INNER JOIN
	(
		SELECT
			surface_id,
			Count(watercourse_id),
			Avg(watercourse_width) AS watercourse_width_avg,
			Max(watercourse_width) AS watercourse_width_max,
			Min(watercourse_width) AS watercourse_width_min
		FROM
			_tmp_surface_watercourses
		GROUP BY
			surface_id
	) SA
	ON 
		SA.surface_id = w.surface_id
	AND
		w.watercourse_width < SA.watercourse_width_avg
) SB
WHERE
	w.watercourse_id = SB.watercourse_id
AND
	w.watercourse_width > 10;

-- Disable watercourses which pass through both ends of the waterbody, as in these
-- cases there likely isn't enough space for a linear label.
UPDATE
	watercourse w
SET
	watercourse_allow_linear_label = false
FROM
(
	SELECT
		w.watercourse_id
	FROM
		_tmp_surface_watercourses sw
	LEFT JOIN
		surface s
	ON
		s.surface_id = sw.surface_id
	INNER JOIN
		watercourse w
	ON
		w.watercourse_id = sw.watercourse_id
	AND
		w.watercourse_allow_linear_label = true
	WHERE
		ST_Crosses(s.surface_geom, w.watercourse_geom)
	AND
		ST_NumGeometries(ST_Intersection(w.watercourse_geom, ST_Boundary(s.surface_geom))) >= 2
) SA
WHERE
	w.watercourse_id = SA.watercourse_id
AND
	w.watercourse_width > 10;

DROP TABLE IF EXISTS _tmp_surface_watercourses;