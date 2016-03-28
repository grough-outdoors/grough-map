SET enable_seqscan=off;
SET enable_bitmapscan=off;

DROP TABLE IF EXISTS edge_oproad_matching;
CREATE TABLE
	edge_oproad_matching
AS
SELECT
	gid AS oproad_id,
	edge_id,
	geom_oproad,
	geom_edge,
	hausdorff,
	length_fraction_a,
	length_fraction_b
FROM
(
	SELECT
		*,
		CASE WHEN ST_LineLocatePoint(oproad_sub_geom, ST_ClosestPoint(oproad_sub_geom, ST_StartPoint(edge_sub_geom))) <
			  ST_LineLocatePoint(oproad_sub_geom, ST_ClosestPoint(oproad_sub_geom, ST_EndPoint(edge_sub_geom))) 
			THEN ST_LineSubstring(
				oproad_sub_geom,
				ST_LineLocatePoint(oproad_sub_geom, ST_ClosestPoint(oproad_sub_geom, ST_StartPoint(edge_sub_geom))),
				ST_LineLocatePoint(oproad_sub_geom, ST_ClosestPoint(oproad_sub_geom, ST_EndPoint(edge_sub_geom)))
			)
			ELSE ST_LineSubstring(
				oproad_sub_geom,
				ST_LineLocatePoint(oproad_sub_geom, ST_ClosestPoint(oproad_sub_geom, ST_EndPoint(edge_sub_geom))),
				ST_LineLocatePoint(oproad_sub_geom, ST_ClosestPoint(oproad_sub_geom, ST_StartPoint(edge_sub_geom)))
			)
		END AS geom_oproad,
		CASE WHEN ST_LineLocatePoint(edge_sub_geom, ST_ClosestPoint(edge_sub_geom, ST_StartPoint(oproad_sub_geom))) <
			  ST_LineLocatePoint(edge_sub_geom, ST_ClosestPoint(edge_sub_geom, ST_EndPoint(oproad_sub_geom))) 
			THEN ST_LineSubstring(
				edge_sub_geom,
				ST_LineLocatePoint(edge_sub_geom, ST_ClosestPoint(edge_sub_geom, ST_StartPoint(oproad_sub_geom))),
				ST_LineLocatePoint(edge_sub_geom, ST_ClosestPoint(edge_sub_geom, ST_EndPoint(oproad_sub_geom)))
			)
			ELSE ST_LineSubstring(
				edge_sub_geom,
				ST_LineLocatePoint(edge_sub_geom, ST_ClosestPoint(edge_sub_geom, ST_EndPoint(oproad_sub_geom))),
				ST_LineLocatePoint(edge_sub_geom, ST_ClosestPoint(edge_sub_geom, ST_StartPoint(oproad_sub_geom)))
			)
		END AS geom_edge,
		ST_HausdorffDistance(
			CASE WHEN ST_LineLocatePoint(oproad_sub_geom, ST_ClosestPoint(oproad_sub_geom, ST_StartPoint(edge_sub_geom))) <
				  ST_LineLocatePoint(oproad_sub_geom, ST_ClosestPoint(oproad_sub_geom, ST_EndPoint(edge_sub_geom))) 
				THEN ST_LineSubstring(
					oproad_sub_geom,
					ST_LineLocatePoint(oproad_sub_geom, ST_ClosestPoint(oproad_sub_geom, ST_StartPoint(edge_sub_geom))),
					ST_LineLocatePoint(oproad_sub_geom, ST_ClosestPoint(oproad_sub_geom, ST_EndPoint(edge_sub_geom)))
				)
				ELSE ST_LineSubstring(
					oproad_sub_geom,
					ST_LineLocatePoint(oproad_sub_geom, ST_ClosestPoint(oproad_sub_geom, ST_EndPoint(edge_sub_geom))),
					ST_LineLocatePoint(oproad_sub_geom, ST_ClosestPoint(oproad_sub_geom, ST_StartPoint(edge_sub_geom)))
				)
			END,
			CASE WHEN ST_LineLocatePoint(edge_sub_geom, ST_ClosestPoint(edge_sub_geom, ST_StartPoint(oproad_sub_geom))) <
				  ST_LineLocatePoint(edge_sub_geom, ST_ClosestPoint(edge_sub_geom, ST_EndPoint(oproad_sub_geom))) 
				THEN ST_LineSubstring(
					edge_sub_geom,
					ST_LineLocatePoint(edge_sub_geom, ST_ClosestPoint(edge_sub_geom, ST_StartPoint(oproad_sub_geom))),
					ST_LineLocatePoint(edge_sub_geom, ST_ClosestPoint(edge_sub_geom, ST_EndPoint(oproad_sub_geom)))
				)
				ELSE ST_LineSubstring(
					edge_sub_geom,
					ST_LineLocatePoint(edge_sub_geom, ST_ClosestPoint(edge_sub_geom, ST_EndPoint(oproad_sub_geom))),
					ST_LineLocatePoint(edge_sub_geom, ST_ClosestPoint(edge_sub_geom, ST_StartPoint(oproad_sub_geom)))
				)
			END
		) AS Hausdorff,
		ST_Length(
			CASE WHEN ST_LineLocatePoint(oproad_sub_geom, ST_ClosestPoint(oproad_sub_geom, ST_StartPoint(edge_sub_geom))) <
				  ST_LineLocatePoint(oproad_sub_geom, ST_ClosestPoint(oproad_sub_geom, ST_EndPoint(edge_sub_geom))) 
				THEN ST_LineSubstring(
					edge_sub_geom,
					ST_LineLocatePoint(oproad_sub_geom, ST_ClosestPoint(oproad_sub_geom, ST_StartPoint(edge_sub_geom))),
					ST_LineLocatePoint(oproad_sub_geom, ST_ClosestPoint(oproad_sub_geom, ST_EndPoint(edge_sub_geom)))
				)
				ELSE ST_LineSubstring(
					edge_sub_geom,
					ST_LineLocatePoint(oproad_sub_geom, ST_ClosestPoint(oproad_sub_geom, ST_EndPoint(edge_sub_geom))),
					ST_LineLocatePoint(oproad_sub_geom, ST_ClosestPoint(oproad_sub_geom, ST_StartPoint(edge_sub_geom)))
				)
			END
		)/ST_Length(oproad_sub_geom) AS Length_Fraction_A,
		ST_Length(
			CASE WHEN ST_LineLocatePoint(edge_sub_geom, ST_ClosestPoint(edge_sub_geom, ST_StartPoint(oproad_sub_geom))) <
				  ST_LineLocatePoint(edge_sub_geom, ST_ClosestPoint(edge_sub_geom, ST_EndPoint(oproad_sub_geom))) 
				THEN ST_LineSubstring(
					edge_sub_geom,
					ST_LineLocatePoint(edge_sub_geom, ST_ClosestPoint(edge_sub_geom, ST_StartPoint(oproad_sub_geom))),
					ST_LineLocatePoint(edge_sub_geom, ST_ClosestPoint(edge_sub_geom, ST_EndPoint(oproad_sub_geom)))
				)
				ELSE ST_LineSubstring(
					edge_sub_geom,
					ST_LineLocatePoint(edge_sub_geom, ST_ClosestPoint(edge_sub_geom, ST_EndPoint(oproad_sub_geom))),
					ST_LineLocatePoint(edge_sub_geom, ST_ClosestPoint(edge_sub_geom, ST_StartPoint(oproad_sub_geom)))
				)
			END
		)/ST_Length(edge_sub_geom) AS Length_Fraction_B
	FROM
	(
		SELECT
			e.edge_id,
			o.gid,
			(ST_Dump(ST_CollectionExtract(
				ST_Intersection(
					o.geom,
					ST_Intersection(
						ST_MakeValid(ST_Buffer(o.geom, 25.0, 'endcap=flat join=mitre mitre_limit=20.0')), 
						ST_MakeValid(ST_Buffer(e.edge_geom, 25.0, 'endcap=flat join=mitre mitre_limit=20.0'))
					)
				),
				2
			))).geom 
			AS oproad_sub_geom,
			(ST_Dump(ST_CollectionExtract(
				ST_Intersection(
					e.edge_geom,
					ST_Intersection(
						ST_MakeValid(ST_Buffer(o.geom, 25.0, 'endcap=flat join=mitre mitre_limit=20.0')), 
						ST_MakeValid(ST_Buffer(e.edge_geom, 25.0, 'endcap=flat join=mitre mitre_limit=20.0'))
					)
				),
				2
			))).geom 
			AS edge_sub_geom
		FROM
			_src_os_oproad_road o, edge e
		WHERE
		--	ST_Intersects(o.geom, ST_SetSRID(ST_MakeBox2D(ST_Point(400000,400000), ST_Point(500000, 500000)), 27700))
		--AND
			ST_DWithin( o.geom, e.edge_geom, 10.0 )
		AND
			e.edge_class_id IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 14)
	) AS SB
) AS SA
WHERE
	length_fraction_a > 0.50 AND
	length_fraction_b > 0.50 AND
	hausdorff < 20.0;

SELECT populate_geometry_columns('edge_oproad_matching'::regclass); 
