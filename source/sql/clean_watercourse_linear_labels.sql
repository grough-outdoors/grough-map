UPDATE
	watercourse
SET
	watercourse_allow_linear_label = false
WHERE
	watercourse_id
IN (
	SELECT
		watercourse_id
	FROM
	(
		SELECT
			*,
			ST_CollectionExtract(ST_Multi(ST_Intersection(watercourse_geom, surface_geom)), 2) AS watercourse_clip_geom
		FROM
		(
			SELECT
				watercourse_id,
				watercourse_geom,
				ST_Multi(ST_MakeValid(ST_Simplify(ST_Difference(
					surface_geom_clip,
					ST_MakeValid(ST_Buffer(surface_geom, -50.0))
				), 20.0))) AS surface_geom
			FROM
			(
				SELECT
					watercourse_id,
					watercourse_geom,
					surface_geom,
					ST_Buffer(ST_MakeValid(ST_Buffer(surface_geom, -30.0)), 30.0) AS surface_geom_clip
				FROM
					_tmp_surface_coarse
			) SA
		) SAA
	) SB
	WHERE
		ST_GeometryType(surface_geom) = 'ST_MultiPolygon'
	AND
		ST_Length(watercourse_clip_geom) > 0.05 * ST_Length(watercourse_geom)
	AND
		ST_NumGeometries(watercourse_clip_geom) <= 1
);
