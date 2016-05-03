DROP TABLE IF EXISTS _tmp_obstructions;

CREATE TABLE _tmp_obstructions AS
SELECT
	*
FROM
(
	SELECT
		ST_ExteriorRing((ST_Dump(zone_line_geom)).geom) AS obstruction_geom,
		ST_Multi(zone_line_geom) AS obstruction_polygon,
		--(ST_Dump(zone_line_geom)).geom AS obstruction_geom,
		zone_geom AS obstruction_zone
	FROM
	(
		SELECT
			zone_id,
			first(zone_geom) AS zone_geom,
			ST_Simplify(ST_LineMerge(ST_Multi(ST_Collect(zone_line_geom))), 2.5) AS zone_real_line_geom,
			ST_Difference(
				ST_MakeValid(ST_Buffer(first(zone_geom), -1.5, 'endcap=square join=bevel')),
				ST_Buffer(ST_MakeValid(ST_Buffer(first(zone_geom), -6.0, 'endcap=square join=bevel')), 10.0)
			) AS zone_line_geom,
			Sum(zone_line_len_base) AS zone_line_len_base,
			Sum(zone_line_len_added) AS zone_line_len_added
		FROM
		(
			SELECT
				zone_id,
				zone_geom,
				o.base AS zone_line_base,
				ST_SnapToGrid(o.geom, 1.0) AS zone_line_geom,
				CASE WHEN o.base = true THEN ST_Length(o.geom) 
				     ELSE 0.0
				END AS zone_line_len_base,
				CASE WHEN o.base = false THEN ST_Length(o.geom) 
				     ELSE 0.0
				END AS zone_line_len_added
			FROM
			(
				SELECT
					ROW_NUMBER() OVER () AS zone_id,
					zone_geom
				FROM
				(
					SELECT
						(ST_Dump(zone_geom)).geom AS zone_geom
					FROM
					(
						SELECT
							ST_Union(ST_Buffer(geom, 2.5, 'endcap=square')) AS zone_geom
						FROM
							_src_obstructions
						GROUP BY
							true
					) SA
				) SAA
			) SB
			LEFT JOIN
				_src_obstructions o
			ON
				o.geom && SB.zone_geom
			AND
				ST_Intersects(o.geom, SB.zone_geom)
		) SC
		GROUP BY
			zone_id
		--HAVING
		--	Sum(zone_line_len_base) > Sum(zone_line_len_added)
	) SD
	WHERE
		ST_Length(zone_real_line_geom) > 200.0	-- Total length
) SE
WHERE
	ST_Length(obstruction_geom) > 5.0;		-- Segment length;

SELECT Populate_Geometry_Columns('_tmp_obstructions'::regclass);