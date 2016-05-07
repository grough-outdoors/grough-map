-- Reduce number of contour peaks by only keeping the maximum within a distance
DELETE FROM
	_tmp_contour_peaks
USING
(
	SELECT
		zone_id,
		first(zone_geom) AS zone_geom,
		Count(p.elevation_id) AS zone_count,
		Max(p.elevation_level) AS zone_max
	FROM
	(
		SELECT
			ROW_NUMBER() OVER () AS zone_id,
			zone_geom
		FROM
		(
			SELECT
				(ST_Dump(ST_Union(ST_Buffer(elevation_geom_centroid, 500.0)))).geom AS zone_geom
			FROM
				_tmp_contour_peaks
		) SAA
	) SA
	LEFT JOIN
		_tmp_contour_peaks p
	ON
		p.elevation_geom_centroid && SA.zone_geom
	AND
		ST_Intersects(p.elevation_geom_centroid, SA.zone_geom)
	GROUP BY
		zone_id
	HAVING
		Count(p.elevation_id) > 0
) SB
WHERE
	ST_Intersects(elevation_geom_centroid, SB.zone_geom)
AND
	zone_max != elevation_level;

CREATE TABLE
	_tmp_contour_lines
AS
SELECT
	ROW_NUMBER() OVER () AS line_id,
	elevation_id,
	elevation_geom_centroid,
	elevation_level AS elevation_peak,
	ST_Multi(ST_MakeLine(
		elevation_geom_centroid, 
		ST_Translate(
			elevation_geom_centroid, 
			sin(radians(angle)) * 5000.0, 
			cos(radians(angle)) * 5000.0
		)
	)) AS elevation_line
FROM
	_tmp_contour_peaks
LEFT JOIN 
	generate_series(5, 355, 10) AS angle ON true;
-- TODO: Join and clip on label zones also?

CREATE INDEX "Idx: _tmp_contour_lines::elevation_line"
	ON _tmp_contour_lines
	USING gist
	(elevation_line);

-- Clip lines where elevation starts to rise
UPDATE
	_tmp_contour_lines
SET
	elevation_line=ST_Multi(line_geom)
FROM
(
	SELECT
		line_id,
		ST_Line_Locate_Point(first(elevation_line), first(elevation_intersection)) AS line_fraction,
		ST_Line_Substring(first(elevation_line), 0.0, ST_Line_Locate_Point(first(elevation_line), first(elevation_intersection))) AS line_geom
	FROM
	(
		SELECT
			line_id,
			elevation_level,
			elevation_level_change,
			elevation_intersection,
			elevation_line
		FROM
		(
			SELECT
				*
			FROM
			(
				SELECT
					line_id,
					elevation_line,
					elevation_level,
					elevation_level - lag(elevation_level) OVER (PARTITION BY line_id ORDER BY ST_Distance(elevation_geom_centroid, elevation_intersection) ASC) AS elevation_level_change,
					elevation_distance,
					elevation_intersection,
					elevation_geom_centroid
				FROM
				(
					SELECT
						*,
						ST_Distance(elevation_geom_centroid, elevation_intersection) AS elevation_distance
					FROM
					(
						SELECT
							p.line_id,
							ST_GeometryN(p.elevation_line, 1) AS elevation_line,
							p.elevation_geom_centroid,
							c.elevation_geom,
							c.elevation_level,
							(ST_Dump(ST_Intersection(p.elevation_line, c.elevation_geom))).geom AS elevation_intersection
						FROM
							_tmp_contour_lines p, _tmp_contour_segments c
						WHERE
							c.elevation_geom && p.elevation_line
						AND
							ST_Intersects(p.elevation_line, c.elevation_geom)
					) SAB
				) SAA
			) SA
			WHERE
				elevation_level_change IS NOT NULL
		) SB
		WHERE
			elevation_level_change >= 0
		ORDER BY
			line_id,
			ST_Distance(elevation_geom_centroid, elevation_intersection) ASC
	) SBA
	GROUP BY
		line_id
) SC
WHERE
	_tmp_contour_lines.line_id = SC.line_id;

-- Remove anything we couldn't cap the length of, or anything too short
DELETE FROM
	_tmp_contour_lines
WHERE
	ST_Length(elevation_line) >= 5000 OR ST_Length(elevation_line) < 250.0;

-- Clip to label zones
UPDATE
	_tmp_contour_lines l
SET
	elevation_line = ST_Multi(line_geom)
FROM
(
	SELECT
		line_id,
		ST_Intersection(first(elevation_line), ST_Union(label_zone)) AS line_geom
	FROM
		_tmp_contour_lines c
	LEFT JOIN
		_tmp_label_zone z
	ON
		c.elevation_line && z.label_zone
	AND
		ST_Intersects(c.elevation_line, z.label_zone)
	GROUP BY
		line_id
) SC
WHERE
	l.line_id = SC.line_id;

-- Pick some decent lines out, preference is south
-- TODO: This can be improved substantially, as it doesn't currenly preclude picking two lines
-- which are close together
DELETE FROM
	_tmp_contour_lines c
WHERE
	c.line_id
NOT IN
(
	SELECT
		line_id
	FROM
	(
		SELECT
			*,
			ROW_NUMBER() OVER (PARTITION BY elevation_id, line_southern) AS line_rank
		FROM
		(
			SELECT
				*,
				abs(elevation_full_angle - lag(elevation_full_angle) OVER (PARTITION BY elevation_id, line_southern)) AS angle_delta,
				( abs(elevation_full_angle - lag(elevation_full_angle) OVER (PARTITION BY elevation_id, line_southern)) > 60 ) AS angle_acceptable
			FROM
			(
				SELECT
					*,
					(elevation_full_angle > 95.0 AND elevation_full_angle < 265) AS line_southern
				FROM
				(
					SELECT
						line_id,
						elevation_id,
						ST_Length(elevation_line) / ST_Length(elevation_full_line) AS elevation_full_fraction,
						ST_Length(elevation_full_line) AS elevation_full_length,
						degrees(ST_Azimuth(elevation_geom_centroid, ST_EndPoint(elevation_full_line))) AS elevation_full_angle
					FROM
					(
						SELECT
							*,
							ST_LongestLine(elevation_geom_centroid, elevation_line) AS elevation_full_line
						FROM
							_tmp_contour_lines l
					) SA
				) SB
				WHERE
					elevation_full_fraction > 0.5
				ORDER BY
					(elevation_full_angle > 95.0 AND elevation_full_angle < 265),
					round( elevation_full_fraction / 0.1 ) * 0.1 DESC,
					round( elevation_full_length / 500 ) * 500 DESC,
					elevation_full_angle ASC
			) SC
		) SD
		WHERE
			angle_acceptable = true
	) SE
	WHERE
		( line_southern = true AND line_rank <= 6 )
	OR
		( line_southern = false AND line_rank <= 4 )
);

-- Truncate lines when they intersect 
-- The highest peak takes priority
UPDATE
	_tmp_contour_lines l
SET
	elevation_line = ST_Multi(line_geom)
FROM
(
	SELECT
		line_id,
		ST_Line_Substring(elevation_line, 0.0, ST_Line_Locate_Point(elevation_line, line_truncate_point)) AS line_geom
	FROM
	(
		SELECT DISTINCT ON (line_id)
			line_id,
			elevation_line,
			first_value(line_cross_point) OVER (PARTITION BY line_id ORDER BY ST_Distance(elevation_geom_centroid, line_cross_point) ASC) AS line_truncate_point
		FROM
		(
			SELECT
				A.line_id,
				ST_GeometryN(A.elevation_line, 1) AS elevation_line,
				A.elevation_geom_centroid,
				(ST_Dump(ST_Intersection(A.elevation_line, B.elevation_line))).geom AS line_cross_point
			FROM
				_tmp_contour_lines A, _tmp_contour_lines B
			WHERE
				A.line_id != B.line_id
			AND
				A.elevation_peak > B.elevation_peak
			AND
				A.elevation_line && B.elevation_line
			AND
				ST_Crosses(A.elevation_line, B.elevation_line)
		) SA
	) SB
) SC
WHERE
	l.line_id = SC.line_id;

CREATE TABLE
	_tmp_contour_ladder_zone
AS SELECT
	ROW_NUMBER() OVER () AS zone_id,
	*
FROM
(
	SELECT
		(ST_Dump(ST_Union(ST_Buffer(elevation_line, 50.0, 'endcap=flat')))).geom AS zone_geom,
		first(elevation_geom_centroid) AS zone_origin
	FROM
		_tmp_contour_lines
) SA;

CREATE INDEX "Idx: _tmp_contour_ladder_zone::zone_geom"
	ON _tmp_contour_ladder_zone
	USING gist
	(zone_geom);

CREATE TABLE
	_tmp_contour_label_primary
AS SELECT
	--ST_Centroid(elevation_geom) AS elevation_geom,
	first(ST_Line_Interpolate_Point(elevation_geom, 0.5)) AS elevation_geom,
	first(elevation_level) AS elevation_level,
	(360 - degrees(ST_Azimuth(ST_StartPoint(first(elevation_geom)), ST_EndPoint(first(elevation_geom)))) + 270)::integer % 360 AS elevation_text_rotate
FROM
(
	SELECT
		*,
		ST_Length(elevation_geom) AS elevation_geom_length
	FROM
	(
		SELECT 
			e.elevation_id,
			z.zone_id AS ladder_id,
			(ST_Dump(ST_Multi(ST_CollectionExtract(ST_Intersection(e.elevation_geom, z.zone_geom), 2)))).geom AS elevation_geom,
			e.elevation_level,
			z.zone_origin
		FROM
			_tmp_contour_segments e, _tmp_contour_ladder_zone z
		WHERE
			e.elevation_geom && z.zone_geom
		AND
			ST_Intersects(e.elevation_geom, z.zone_geom)
	) SB
	ORDER BY
		ladder_id,
		elevation_id,
		ST_Length(elevation_geom) DESC
) SA
GROUP BY
	ladder_id, elevation_id;

/*
CREATE TABLE
	_tmp_contour_label_secondary
AS SELECT 
	elevation_id,
	ST_Multi(ST_CollectionExtract(ST_Difference(first(e.elevation_geom), ST_Union(z.zone_geom)), 2)) AS elevation_geom,
	first(e.elevation_level) AS elevation_level
FROM
	_tmp_contour_segments e
LEFT JOIN
	(SELECT ST_Buffer(zone_geom, 250.0, 'quad_segs=2') AS zone_geom FROM _tmp_contour_ladder_zone ) z
ON
	e.elevation_geom && z.zone_geom
GROUP BY
	e.elevation_id;

CREATE INDEX "Idx: _tmp_contour_label_secondary::elevation_geom"
	ON _tmp_contour_label_secondary
	USING gist
	(elevation_geom);

-- Clip to label zones
UPDATE
	_tmp_contour_label_secondary l
SET
	elevation_geom = ST_Multi(line_geom)
FROM
(
	SELECT
		c.elevation_id,
		ST_Intersection(first(elevation_geom), ST_Union(label_zone)) AS line_geom
	FROM
		_tmp_contour_label_secondary c
	LEFT JOIN
		_tmp_label_zone z
	ON
		c.elevation_geom && z.label_zone
	GROUP BY
		c.elevation_id
) SC
WHERE
	l.elevation_id = SC.elevation_id;
*/

SELECT populate_geometry_columns('_tmp_contour_label_primary'::regclass);
--SELECT populate_geometry_columns('_tmp_contour_label_secondary'::regclass);
SELECT populate_geometry_columns('_tmp_contour_label_rings'::regclass);
SELECT populate_geometry_columns('_tmp_contour_segments'::regclass); 
SELECT populate_geometry_columns('_tmp_contour_peaks'::regclass); 
SELECT populate_geometry_columns('_tmp_contour_lines'::regclass); 
SELECT populate_geometry_columns('_tmp_contour_ladder_zone'::regclass); 

DROP TABLE IF EXISTS _tmp_contour_segments;
DROP TABLE IF EXISTS _tmp_contour_peaks;
DROP TABLE IF EXISTS _tmp_contour_lines;
DROP TABLE IF EXISTS _tmp_contour_ladder_zone;
