-- Should have at least two levels matching 
-- Should have a minimum fraction of 0.5 at lower levels, maximum fraction will be 1.0 at most
DELETE FROM
	_src_obstructions_unclean
WHERE
	id 
IN
(
	SELECT
		id
	FROM
	(
		SELECT
			id,
			lev,
			first(geom_fraction) AS geom_fraction,
			Count(id) OVER (PARTITION BY id) AS level_count,
			lag(Min(geom_fraction)) OVER (PARTITION BY id ORDER BY lev) AS geom_fraction_min
		FROM
		(
			SELECT
				id,
				lev,
				Sum(geom_length) / first(geom_total_length) AS geom_fraction,
				Sum(geom_length) AS geom_length
			FROM
			(
				SELECT
					id,
					lev,
					lev_id,
					geom_heading,
					(degrees(ST_Azimuth(ST_StartPoint(lev_segment), ST_EndPoint(lev_segment))) + 180)::integer % 180 AS lev_heading,
					ST_Length(lev_segment) AS lev_length,
					geom_length,
					geom_total_length
				FROM
				(
					SELECT
						id,
						lev,
						gid AS lev_id,
						ST_Intersection(
							lev_geom,
							ST_Buffer(geom_segment, 5.0, 'endcap=flat')
						) AS lev_segment,
						(degrees(ST_Azimuth(ST_StartPoint(geom_segment), ST_EndPoint(geom_segment))) + 180)::integer % 180 AS geom_heading,
						ST_Length(geom_segment) AS geom_length,
						geom_total_length
					FROM
					(
						SELECT
							o.id,
							SA.gid,
							SA.lev,
							SA.geom AS lev_geom,
							ST_Length(o.geom) AS geom_total_length,
							(ST_Dump(ST_Intersection(
								o.geom,
								ST_Buffer(SA.geom, 5.0, 'endcap=flat')
							))).geom AS geom_segment
						FROM
							_src_obstructions_unclean o
						LEFT JOIN
						(
							SELECT
								gid,
								geom,
								1 AS lev
							FROM
								_src_obstructions_lev1
							UNION SELECT
								gid,
								geom,
								2 AS lev
							FROM
								_src_obstructions_lev2
							UNION SELECT
								gid,
								geom,
								3 AS lev
							FROM
								_src_obstructions_lev3
						) SA
						ON
							ST_DWithin(o.geom, SA.geom, 1)
					) SA
				) SB
			) SC
			WHERE
				abs(lev_heading - geom_heading) < 15
			GROUP BY
				id,
				lev
		) SD
		GROUP BY
			id,
			lev
		ORDER BY
			id ASC,
			lev ASC
	) SE
	WHERE
		geom_fraction_min < 0.4
	OR
		level_count < 2
)