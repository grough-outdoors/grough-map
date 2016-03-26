DROP TABLE IF EXISTS 
	_src_prow__areas;

DROP INDEX IF EXISTS
	"Idx: _src_prow::geom";

CREATE INDEX "Idx: _src_prow::geom"
	ON _src_prow USING gist (geom);
	   
ALTER TABLE _src_prow
	CLUSTER ON "Idx: _src_prow::geom";

CREATE TABLE
	_src_prow__areas
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
	_src_prow__areas
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
	_src_prow__areas b
ON
	a.geom && b.geom_full
AND
	ST_Contains(ST_Buffer(b.geom_full, 500), ST_Simplify(a.geom, 50))
WHERE
	b.name IS NULL;

UPDATE 
	_src_prow__areas
SET
	prow_approx_coverage = Least(ST_Area(path_convex_hull)/ST_Area(a.geom_full), 1.0)::double precision,
	prow_approx_length = path_total_length::double precision,
	prow_status = CASE
		WHEN path_total_length > 1000.0 AND Least(ST_Area(path_convex_hull)/ST_Area(a.geom_full), 1.0) > 0.4 THEN 'Full coverage'
		WHEN path_total_length > 1000.0 AND Least(ST_Area(path_convex_hull)/ST_Area(a.geom_full), 1.0) <= 0.4 THEN 'Partial coverage'
		ELSE 'No coverage'
	END
FROM
	_src_prow__areas a
LEFT JOIN
	(
		SELECT
			a.name AS path_area_name,
			Sum(ST_Length(p.geom)) AS path_total_length,
			CASE WHEN Count(p.geom) > 0 THEN ST_ConvexHull(ST_Collect(p.geom)) 
			     ELSE ST_GeomFromText('POLYGON EMPTY')
			     END AS path_convex_hull
		FROM
			_src_prow__areas a
		LEFT JOIN
			_src_prow p
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
	_src_prow__areas.name = a.name;

SELECT populate_geometry_columns('_src_prow__areas'::regclass); 