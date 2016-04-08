UPDATE
	watercourse w
SET
	watercourse_name = osm_name,
	watercourse_class_id = CASE WHEN reservoir = true THEN 5
			            ELSE watercourse_class_id
			       END
FROM
(
	SELECT
		w.watercourse_id,
		w.watercourse_name AS wc_name,
		p.name AS osm_name,
		CASE WHEN lower(p.landuse) = 'reservoir' OR lower(p.water) = 'reservoir' THEN true
		     ELSE false
		END as reservoir
	FROM
		_src_osm_polygon_water p, watercourse w
	WHERE
		w.watercourse_class_id IN (4, 5)
	AND
		ST_Intersects(w.watercourse_geom, p.way)
	AND
		ST_Length(ST_Intersection(w.watercourse_geom, p.way)) > ST_Length(w.watercourse_geom) * 0.9
	AND
		p.name IS NOT NULL
	AND
		levenshtein(unaccent(p.name), unaccent(w.watercourse_name)) > 0
	AND
	(
			lower(unaccent(w.watercourse_name)) LIKE '%river%'
		OR
			lower(unaccent(w.watercourse_name)) LIKE '%beck%'
		OR
			lower(unaccent(w.watercourse_name)) LIKE '%stream%'
		OR
			lower(unaccent(w.watercourse_name)) LIKE '%afon%'
		OR
			-- This is a list -- probably not definitive -- of terms which mean lakes etc.
			(
				lower(unaccent(w.watercourse_name)) NOT LIKE '%loch%'
			AND
				lower(unaccent(w.watercourse_name)) NOT LIKE '%lake%'
			AND
				lower(unaccent(w.watercourse_name)) NOT LIKE '%water%'
			AND
				lower(unaccent(w.watercourse_name)) NOT LIKE '%tarn%'
			AND
				lower(unaccent(w.watercourse_name)) NOT LIKE '%water%'
			AND
				lower(unaccent(w.watercourse_name)) NOT LIKE '%reservoir%'
			AND
				lower(unaccent(w.watercourse_name)) NOT LIKE '%pool%'
			)
	)
) SA
WHERE SA.watercourse_id = w.watercourse_id;