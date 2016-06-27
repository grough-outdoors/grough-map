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
				watercourse_id,
				watercourse_geom,
				surface_full_area,
				CASE WHEN ST_Area(surface_shrink_400m) >= surface_full_area * 0.25 THEN surface_shrink_400m
				     WHEN ST_Area(surface_shrink_200m) >= surface_full_area * 0.25 THEN surface_shrink_200m
				     WHEN ST_Area(surface_shrink_50m) >= surface_full_area * 0.25 THEN surface_shrink_50m
				     ELSE surface_0m
				END AS surface_shrink
			FROM
			(
				SELECT
					w.watercourse_id,
					w.watercourse_geom,
					ST_Area(s.surface_geom) AS surface_full_area,
					ST_CollectionExtract(ST_Multi(s.surface_geom), 3) AS surface_0m,
					ST_CollectionExtract(ST_MakeValid(ST_Buffer(s.surface_geom, -50.0)), 3) AS surface_shrink_50m,
					ST_CollectionExtract(ST_MakeValid(ST_Buffer(s.surface_geom, -200.0)), 3) AS surface_shrink_200m,
					ST_CollectionExtract(ST_MakeValid(ST_Buffer(s.surface_geom, -400.0)), 3) AS surface_shrink_400m
				FROM
					_tmp_surface_coarse s
				INNER JOIN
					watercourse w
				ON
					s.watercourse_id = w.watercourse_id
				AND
					w.watercourse_class_id IN (1, 4, 5)
				AND
					ST_Within(w.watercourse_geom, s.surface_geom)
			) SAA
		) SA
	) SB
	WHERE
		watercourse_shrink_length <= watercourse_full_length * 0.5
);

-- TODO: Remove labels from anything which isn't near a surface (could be culverts, could just be rubbish line quality)

-- TODO: Limit the labels only to the most central parts of a waterbody (e.g. Windermere)
