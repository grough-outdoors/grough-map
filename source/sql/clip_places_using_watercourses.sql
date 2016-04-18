UPDATE
	place
SET
	place_geom = SB.place_geom
FROM
(
	SELECT
		place_id,
		place_centre_geom,
		place_geom_original_area,
		ST_Area(geom) AS place_geom_new_area,
		ST_Area(geom) / place_geom_original_area AS place_geom_new_fraction,
		ST_Multi(geom) AS place_geom
	FROM
	(
		SELECT
			p.place_id,
			p.place_centre_geom,
			ST_Area(place_geom) AS place_geom_original_area,
			(ST_Dump(ST_Difference(p.place_geom, ST_Buffer(ST_Collect(w.watercourse_geom), 20.0, 'endcap=flat')))).*
		FROM
			place p
		LEFT JOIN
			watercourse w
		ON
			p.place_geom && w.watercourse_geom
		AND
			w.watercourse_class_id IN (1, 3, 4, 5)
		AND
			w.watercourse_width > 5
		GROUP BY
			p.place_id, p.place_geom, p.place_centre_geom
	) SA
	WHERE
		ST_Within(place_centre_geom, geom)
) SB
WHERE 
	SB.place_id = place.place_id
AND
	place_geom_new_fraction > 0.4;