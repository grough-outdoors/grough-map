INSERT INTO
	place
	(place_class_id, place_centre_geom, place_geom, place_name)
SELECT
	CASE WHEN surface_area_km > 3.0 THEN 13
	     ELSE 12
	     END AS place_class_id,
	ST_Centroid(surface_geom) AS place_centre_geom,
	ST_Multi(ST_MakeValid(ST_Simplify(surface_geom, 10.0))) AS place_geom,
	watercourse_name AS place_name
FROM
(
	SELECT
		SC.*,
		surface_geom,
		ST_Area(surface_geom) / 1000000 AS surface_area_km
	FROM
	(
		SELECT
			surface_id,
			first(watercourse_name) AS watercourse_name,
			first(watercourse_length) / 1000 AS watercourse_length_km,
			first(watercourse_length) / Sum(watercourse_length) AS watercourse_fraction
		FROM
		(
			SELECT
				surface_id,
				watercourse_name,
				Sum(watercourse_length) AS watercourse_length
			FROM
			(
				SELECT
					s.surface_id,
					w.watercourse_name,
					ST_Length(w.watercourse_geom) AS watercourse_length
				FROM
					surface s, watercourse w
				WHERE
					s.surface_class_id = 6 AND w.watercourse_class_id IN (4, 5)
				AND
					s.surface_geom && w.watercourse_geom
				AND
					ST_Intersects(s.surface_geom, w.watercourse_geom)
				AND
					watercourse_name IS NOT NULL
			) SA
			GROUP BY
				surface_id, watercourse_name
			ORDER BY
				surface_id, watercourse_length DESC
		) SB
		GROUP BY
			surface_id
		HAVING 
			first(watercourse_length) / Sum(watercourse_length) > 0.75
	) SC
	LEFT JOIN
		surface s
	ON
		SC.surface_id = s.surface_id
) SD;