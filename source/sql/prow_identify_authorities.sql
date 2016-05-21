DROP TABLE IF EXISTS 
	raw_prow_authorities;

DROP INDEX IF EXISTS
	"Idx: raw_prow::geom";

CREATE INDEX "Idx: raw_prow::geom"
	ON raw_prow USING gist (geom);
	   
ALTER TABLE raw_prow
	CLUSTER ON "Idx: raw_prow::geom";

CREATE TABLE
	raw_prow_authorities
AS SELECT
	replace("name", ' County', '') AS "name",
	ST_MakeValid(ST_Simplify("geom", 100)) AS "geom_full",
	ST_MakeValid(ST_Buffer(ST_Simplify("geom", 100), -250)) AS "geom_small",
	'No coverage'::character varying AS "prow_status",
	0.0::double precision AS "prow_approx_coverage",
	0.0::double precision AS "prow_approx_length"
FROM
	_src_os_bdline_county_region;

INSERT INTO
	raw_prow_authorities
SELECT
	replace(replace(a."name", ' District', ''), ' (B)', '') AS "name",
	ST_MakeValid(ST_Simplify(a."geom", 100)) AS "geom_full",
	ST_MakeValid(ST_Buffer(ST_Simplify(a."geom", 100), -250)) AS "geom_small",
	'No coverage'::character varying AS "prow_status",
	0.0::double precision AS "prow_approx_coverage",
	0.0::double precision AS "prow_approx_length"
FROM
	_src_os_bdline_district_borough_unitary_region a
LEFT JOIN
	raw_prow_authorities b
ON
	a.geom && b.geom_full
AND
	ST_Contains(ST_Buffer(b.geom_full, 500), ST_Simplify(a.geom, 50))
WHERE
	b.name IS NULL;

UPDATE 
	raw_prow_authorities
SET
	prow_approx_coverage = Least(ST_Area(path_convex_hull)/ST_Area(a.geom_full), 1.0)::double precision,
	prow_approx_length = path_total_length::double precision,
	prow_status = CASE
		WHEN path_total_length > 1000.0 AND Least(ST_Area(path_convex_hull)/ST_Area(a.geom_full), 1.0) > 0.4 THEN 'Full coverage'
		WHEN path_total_length > 1000.0 AND Least(ST_Area(path_convex_hull)/ST_Area(a.geom_full), 1.0) <= 0.4 THEN 'Partial coverage'
		ELSE 'No coverage'
	END
FROM
	raw_prow_authorities a
LEFT JOIN
	(
		SELECT
			a.name AS path_area_name,
			Sum(ST_Length(p.geom)) AS path_total_length,
			CASE WHEN Count(p.geom) > 0 THEN ST_ConvexHull(ST_Collect(p.geom)) 
			     ELSE ST_GeomFromText('POLYGON EMPTY')
			     END AS path_convex_hull
		FROM
			raw_prow_authorities a
		LEFT JOIN
			raw_prow p
		ON
			p.geom && a.geom_full
		AND
			ST_Within(p.geom, a.geom_small)
		GROUP BY
			a.name
	) b
ON
	a.name = b.path_area_name
WHERE
	raw_prow_authorities.name = a.name;

SELECT populate_geometry_columns('raw_prow_authorities'::regclass); 