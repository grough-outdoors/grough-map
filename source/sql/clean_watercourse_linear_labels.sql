-- Disable labels on waterbodies (reservoirs and lakes) which are too small for a linear label to really work
UPDATE
	watercourse
SET
	watercourse_allow_linear_label = false
WHERE
	watercourse_id
IN
(
	SELECT
		watercourse_id
	FROM
	(
		SELECT
			watercourse_id,
			ST_Length(watercourse_geom) AS watercourse_full_length,
			ST_Length(ST_Intersection(watercourse_geom, surface_shrink)) AS watercourse_shrink_length,
			surface_full_area,
			ST_Area(surface_shrink) AS surface_shrink_area
		FROM
		(
			SELECT
				w.watercourse_id,
				w.watercourse_geom,
				ST_Area(s.surface_geom) AS surface_full_area,
				ST_MakeValid(ST_Buffer(s.surface_geom, -50.0)) AS surface_shrink
			FROM
				_tmp_surface_coarse s
			INNER JOIN
				watercourse w
			ON
				s.watercourse_id = w.watercourse_id
			AND
				w.watercourse_class_id IN (1, 4, 5)
		) SA
	) SB
	WHERE
		watercourse_shrink_length <= watercourse_full_length * 0.5
	OR
		surface_shrink_area <= surface_full_area * 0.5
);

-- TODO: Remove labels from anything which isn't near a surface (could be culverts, could just be rubbish line quality)

-- TODO: Limit the labels only to the most central parts of a waterbody (e.g. Windermere)
