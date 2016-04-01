SET enable_seqscan=off;
SET enable_bitmapscan=off;

DROP TABLE IF EXISTS opmlc_oprvrs_matching;
CREATE TABLE
	opmlc_oprvrs_matching
AS
SELECT
	opmlc_id,
	oprvrs_id,
	geom_oprvrs,
	geom_opmlc,
	hausdorff,
	length_fraction_a,
	length_fraction_b
FROM
(
	SELECT
		*,
		CASE WHEN ST_LineLocatePoint(oprvrs_sub_geom, ST_ClosestPoint(oprvrs_sub_geom, ST_StartPoint(opmlc_sub_geom))) <
			  ST_LineLocatePoint(oprvrs_sub_geom, ST_ClosestPoint(oprvrs_sub_geom, ST_EndPoint(opmlc_sub_geom))) 
			THEN ST_LineSubstring(
				oprvrs_sub_geom,
				ST_LineLocatePoint(oprvrs_sub_geom, ST_ClosestPoint(oprvrs_sub_geom, ST_StartPoint(opmlc_sub_geom))),
				ST_LineLocatePoint(oprvrs_sub_geom, ST_ClosestPoint(oprvrs_sub_geom, ST_EndPoint(opmlc_sub_geom)))
			)
			ELSE ST_LineSubstring(
				oprvrs_sub_geom,
				ST_LineLocatePoint(oprvrs_sub_geom, ST_ClosestPoint(oprvrs_sub_geom, ST_EndPoint(opmlc_sub_geom))),
				ST_LineLocatePoint(oprvrs_sub_geom, ST_ClosestPoint(oprvrs_sub_geom, ST_StartPoint(opmlc_sub_geom)))
			)
		END AS geom_oprvrs,
		CASE WHEN ST_LineLocatePoint(opmlc_sub_geom, ST_ClosestPoint(opmlc_sub_geom, ST_StartPoint(oprvrs_sub_geom))) <
			  ST_LineLocatePoint(opmlc_sub_geom, ST_ClosestPoint(opmlc_sub_geom, ST_EndPoint(oprvrs_sub_geom))) 
			THEN ST_LineSubstring(
				opmlc_sub_geom,
				ST_LineLocatePoint(opmlc_sub_geom, ST_ClosestPoint(opmlc_sub_geom, ST_StartPoint(oprvrs_sub_geom))),
				ST_LineLocatePoint(opmlc_sub_geom, ST_ClosestPoint(opmlc_sub_geom, ST_EndPoint(oprvrs_sub_geom)))
			)
			ELSE ST_LineSubstring(
				opmlc_sub_geom,
				ST_LineLocatePoint(opmlc_sub_geom, ST_ClosestPoint(opmlc_sub_geom, ST_EndPoint(oprvrs_sub_geom))),
				ST_LineLocatePoint(opmlc_sub_geom, ST_ClosestPoint(opmlc_sub_geom, ST_StartPoint(oprvrs_sub_geom)))
			)
		END AS geom_opmlc,
		ST_HausdorffDistance(
			CASE WHEN ST_LineLocatePoint(oprvrs_sub_geom, ST_ClosestPoint(oprvrs_sub_geom, ST_StartPoint(opmlc_sub_geom))) <
				  ST_LineLocatePoint(oprvrs_sub_geom, ST_ClosestPoint(oprvrs_sub_geom, ST_EndPoint(opmlc_sub_geom))) 
				THEN ST_LineSubstring(
					oprvrs_sub_geom,
					ST_LineLocatePoint(oprvrs_sub_geom, ST_ClosestPoint(oprvrs_sub_geom, ST_StartPoint(opmlc_sub_geom))),
					ST_LineLocatePoint(oprvrs_sub_geom, ST_ClosestPoint(oprvrs_sub_geom, ST_EndPoint(opmlc_sub_geom)))
				)
				ELSE ST_LineSubstring(
					oprvrs_sub_geom,
					ST_LineLocatePoint(oprvrs_sub_geom, ST_ClosestPoint(oprvrs_sub_geom, ST_EndPoint(opmlc_sub_geom))),
					ST_LineLocatePoint(oprvrs_sub_geom, ST_ClosestPoint(oprvrs_sub_geom, ST_StartPoint(opmlc_sub_geom)))
				)
			END,
			CASE WHEN ST_LineLocatePoint(opmlc_sub_geom, ST_ClosestPoint(opmlc_sub_geom, ST_StartPoint(oprvrs_sub_geom))) <
				  ST_LineLocatePoint(opmlc_sub_geom, ST_ClosestPoint(opmlc_sub_geom, ST_EndPoint(oprvrs_sub_geom))) 
				THEN ST_LineSubstring(
					opmlc_sub_geom,
					ST_LineLocatePoint(opmlc_sub_geom, ST_ClosestPoint(opmlc_sub_geom, ST_StartPoint(oprvrs_sub_geom))),
					ST_LineLocatePoint(opmlc_sub_geom, ST_ClosestPoint(opmlc_sub_geom, ST_EndPoint(oprvrs_sub_geom)))
				)
				ELSE ST_LineSubstring(
					opmlc_sub_geom,
					ST_LineLocatePoint(opmlc_sub_geom, ST_ClosestPoint(opmlc_sub_geom, ST_EndPoint(oprvrs_sub_geom))),
					ST_LineLocatePoint(opmlc_sub_geom, ST_ClosestPoint(opmlc_sub_geom, ST_StartPoint(oprvrs_sub_geom)))
				)
			END
		) AS Hausdorff,
		ST_Length(
			CASE WHEN ST_LineLocatePoint(oprvrs_sub_geom, ST_ClosestPoint(oprvrs_sub_geom, ST_StartPoint(opmlc_sub_geom))) <
				  ST_LineLocatePoint(oprvrs_sub_geom, ST_ClosestPoint(oprvrs_sub_geom, ST_EndPoint(opmlc_sub_geom))) 
				THEN ST_LineSubstring(
					opmlc_sub_geom,
					ST_LineLocatePoint(oprvrs_sub_geom, ST_ClosestPoint(oprvrs_sub_geom, ST_StartPoint(opmlc_sub_geom))),
					ST_LineLocatePoint(oprvrs_sub_geom, ST_ClosestPoint(oprvrs_sub_geom, ST_EndPoint(opmlc_sub_geom)))
				)
				ELSE ST_LineSubstring(
					opmlc_sub_geom,
					ST_LineLocatePoint(oprvrs_sub_geom, ST_ClosestPoint(oprvrs_sub_geom, ST_EndPoint(opmlc_sub_geom))),
					ST_LineLocatePoint(oprvrs_sub_geom, ST_ClosestPoint(oprvrs_sub_geom, ST_StartPoint(opmlc_sub_geom)))
				)
			END
		)/ST_Length(oprvrs_sub_geom) AS Length_Fraction_A,
		ST_Length(
			CASE WHEN ST_LineLocatePoint(opmlc_sub_geom, ST_ClosestPoint(opmlc_sub_geom, ST_StartPoint(oprvrs_sub_geom))) <
				  ST_LineLocatePoint(opmlc_sub_geom, ST_ClosestPoint(opmlc_sub_geom, ST_EndPoint(oprvrs_sub_geom))) 
				THEN ST_LineSubstring(
					opmlc_sub_geom,
					ST_LineLocatePoint(opmlc_sub_geom, ST_ClosestPoint(opmlc_sub_geom, ST_StartPoint(oprvrs_sub_geom))),
					ST_LineLocatePoint(opmlc_sub_geom, ST_ClosestPoint(opmlc_sub_geom, ST_EndPoint(oprvrs_sub_geom)))
				)
				ELSE ST_LineSubstring(
					opmlc_sub_geom,
					ST_LineLocatePoint(opmlc_sub_geom, ST_ClosestPoint(opmlc_sub_geom, ST_EndPoint(oprvrs_sub_geom))),
					ST_LineLocatePoint(opmlc_sub_geom, ST_ClosestPoint(opmlc_sub_geom, ST_StartPoint(oprvrs_sub_geom)))
				)
			END
		)/ST_Length(opmlc_sub_geom) AS Length_Fraction_B
	FROM
	(
		SELECT
			e.gid AS opmlc_id,
			o.gid AS oprvrs_id,
			(ST_Dump(ST_CollectionExtract(
				ST_Intersection(
					o.geom,
					ST_Intersection(
						ST_MakeValid(ST_Buffer(o.geom, 25.0, 'endcap=flat join=mitre mitre_limit=20.0')), 
						ST_MakeValid(ST_Buffer(e.geom, 25.0, 'endcap=flat join=mitre mitre_limit=20.0'))
					)
				),
				2
			))).geom 
			AS oprvrs_sub_geom,
			(ST_Dump(ST_CollectionExtract(
				ST_Intersection(
					e.geom,
					ST_Intersection(
						ST_MakeValid(ST_Buffer(o.geom, 25.0, 'endcap=flat join=mitre mitre_limit=20.0')), 
						ST_MakeValid(ST_Buffer(e.geom, 25.0, 'endcap=flat join=mitre mitre_limit=20.0'))
					)
				),
				2
			))).geom 
			AS opmlc_sub_geom
		FROM
			_src_os_oprvrs_watercourse_link o, _src_os_opmplc_surface_water_line e
		WHERE
			ST_DWithin( o.geom, e.geom, 20.0 )
		AND
			o.name IS NOT NULL
	) AS SB
) AS SA
WHERE
	length_fraction_a > 0.50 AND
	length_fraction_b > 0.50 AND
	hausdorff < 15.0;

SELECT populate_geometry_columns('opmlc_oprvrs_matching'::regclass); 
