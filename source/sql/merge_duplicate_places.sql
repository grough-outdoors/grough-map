DROP TABLE IF EXISTS _tmp_duplicate_names;

-- Identify duplicates
CREATE TABLE _tmp_duplicate_names AS SELECT
	p1.place_id AS p1_place_id,
	p1.place_name AS p1_place_name,
	c1.class_name AS p1_class_name,
	p2.place_id AS p2_place_id,
	p2.place_name AS p2_place_name,
	c2.class_name AS p2_class_name
FROM
	place p1
LEFT JOIN
	place_classes c1
ON
	p1.place_class_id = c1.class_id
INNER JOIN
	place p2
ON
	names_match(p1.place_name, p2.place_name)
AND
	p1.place_id != p2.place_id
AND
	ST_DWithin(p1.place_geom, p2.place_geom, c1.class_aggregate_radius)
LEFT JOIN
	place_classes c2
ON
	p2.place_class_id = c2.class_id
WHERE
	c1.class_text_size > c2.class_text_size
OR
	(c1.class_text_size = c2.class_text_size AND p1.place_id < p2.place_id);

-- Merge the duplicates
UPDATE
	place
SET
	place_geom = ST_Multi(ST_CollectionExtract(ST_MakeValid(SB.place_geom), 3))
FROM
(
	SELECT
		p1_place_id AS place_id,
		ST_Collect(ST_MakeValid(p1_place_geom), ST_MakeValid(p2_place_geom)) AS place_geom
	FROM
	(
		SELECT
			p1_place_id AS p1_place_id,
			p1.place_geom AS p1_place_geom,
			ST_Collect(ST_MakeValid(ST_Intersection(p1.place_geom, p2.place_geom))) AS p2_place_geom
		FROM
			_tmp_duplicate_names d
		LEFT JOIN
			place p1
		ON
			p1.place_id = d.p1_place_id
		LEFT JOIN
			place p2
		ON
			p2.place_id = d.p2_place_id
		GROUP BY
			p1_place_id, p1.place_geom
	) SA
) SB
WHERE
	place.place_id = SB.place_id;

-- Delete the now merged rows
DELETE FROM
	place
USING
(
	SELECT
		p2_place_id AS place_id
	FROM
		_tmp_duplicate_names d
) SB
WHERE
	place.place_id = SB.place_id;

DROP TABLE IF EXISTS _tmp_duplicate_names;