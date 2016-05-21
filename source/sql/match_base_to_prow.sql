DROP TABLE IF EXISTS edge_prow_matching;
CREATE TABLE
	edge_prow_matching
AS
SELECT
	id AS prow_id,
	edge_id,
	type AS prow_type,
	geom_prow,
	geom_edge,
	hausdorff,
	length_fraction_a,
	length_fraction_b
FROM
(
	SELECT
		*,
		CASE WHEN ST_LineLocatePoint(prow_sub_geom, ST_ClosestPoint(prow_sub_geom, ST_StartPoint(edge_sub_geom))) <
			  ST_LineLocatePoint(prow_sub_geom, ST_ClosestPoint(prow_sub_geom, ST_EndPoint(edge_sub_geom))) 
			THEN ST_LineSubstring(
				prow_sub_geom,
				ST_LineLocatePoint(prow_sub_geom, ST_ClosestPoint(prow_sub_geom, ST_StartPoint(edge_sub_geom))),
				ST_LineLocatePoint(prow_sub_geom, ST_ClosestPoint(prow_sub_geom, ST_EndPoint(edge_sub_geom)))
			)
			ELSE ST_LineSubstring(
				prow_sub_geom,
				ST_LineLocatePoint(prow_sub_geom, ST_ClosestPoint(prow_sub_geom, ST_EndPoint(edge_sub_geom))),
				ST_LineLocatePoint(prow_sub_geom, ST_ClosestPoint(prow_sub_geom, ST_StartPoint(edge_sub_geom)))
			)
		END AS geom_prow,
		CASE WHEN ST_LineLocatePoint(edge_sub_geom, ST_ClosestPoint(edge_sub_geom, ST_StartPoint(prow_sub_geom))) <
			  ST_LineLocatePoint(edge_sub_geom, ST_ClosestPoint(edge_sub_geom, ST_EndPoint(prow_sub_geom))) 
			THEN ST_LineSubstring(
				edge_sub_geom,
				ST_LineLocatePoint(edge_sub_geom, ST_ClosestPoint(edge_sub_geom, ST_StartPoint(prow_sub_geom))),
				ST_LineLocatePoint(edge_sub_geom, ST_ClosestPoint(edge_sub_geom, ST_EndPoint(prow_sub_geom)))
			)
			ELSE ST_LineSubstring(
				edge_sub_geom,
				ST_LineLocatePoint(edge_sub_geom, ST_ClosestPoint(edge_sub_geom, ST_EndPoint(prow_sub_geom))),
				ST_LineLocatePoint(edge_sub_geom, ST_ClosestPoint(edge_sub_geom, ST_StartPoint(prow_sub_geom)))
			)
		END AS geom_edge,
		ST_HausdorffDistance(
			CASE WHEN ST_LineLocatePoint(prow_sub_geom, ST_ClosestPoint(prow_sub_geom, ST_StartPoint(edge_sub_geom))) <
				  ST_LineLocatePoint(prow_sub_geom, ST_ClosestPoint(prow_sub_geom, ST_EndPoint(edge_sub_geom))) 
				THEN ST_LineSubstring(
					prow_sub_geom,
					ST_LineLocatePoint(prow_sub_geom, ST_ClosestPoint(prow_sub_geom, ST_StartPoint(edge_sub_geom))),
					ST_LineLocatePoint(prow_sub_geom, ST_ClosestPoint(prow_sub_geom, ST_EndPoint(edge_sub_geom)))
				)
				ELSE ST_LineSubstring(
					prow_sub_geom,
					ST_LineLocatePoint(prow_sub_geom, ST_ClosestPoint(prow_sub_geom, ST_EndPoint(edge_sub_geom))),
					ST_LineLocatePoint(prow_sub_geom, ST_ClosestPoint(prow_sub_geom, ST_StartPoint(edge_sub_geom)))
				)
			END,
			CASE WHEN ST_LineLocatePoint(edge_sub_geom, ST_ClosestPoint(edge_sub_geom, ST_StartPoint(prow_sub_geom))) <
				  ST_LineLocatePoint(edge_sub_geom, ST_ClosestPoint(edge_sub_geom, ST_EndPoint(prow_sub_geom))) 
				THEN ST_LineSubstring(
					edge_sub_geom,
					ST_LineLocatePoint(edge_sub_geom, ST_ClosestPoint(edge_sub_geom, ST_StartPoint(prow_sub_geom))),
					ST_LineLocatePoint(edge_sub_geom, ST_ClosestPoint(edge_sub_geom, ST_EndPoint(prow_sub_geom)))
				)
				ELSE ST_LineSubstring(
					edge_sub_geom,
					ST_LineLocatePoint(edge_sub_geom, ST_ClosestPoint(edge_sub_geom, ST_EndPoint(prow_sub_geom))),
					ST_LineLocatePoint(edge_sub_geom, ST_ClosestPoint(edge_sub_geom, ST_StartPoint(prow_sub_geom)))
				)
			END
		) AS Hausdorff,
		ST_Length(
			CASE WHEN ST_LineLocatePoint(prow_sub_geom, ST_ClosestPoint(prow_sub_geom, ST_StartPoint(edge_sub_geom))) <
				  ST_LineLocatePoint(prow_sub_geom, ST_ClosestPoint(prow_sub_geom, ST_EndPoint(edge_sub_geom))) 
				THEN ST_LineSubstring(
					edge_sub_geom,
					ST_LineLocatePoint(prow_sub_geom, ST_ClosestPoint(prow_sub_geom, ST_StartPoint(edge_sub_geom))),
					ST_LineLocatePoint(prow_sub_geom, ST_ClosestPoint(prow_sub_geom, ST_EndPoint(edge_sub_geom)))
				)
				ELSE ST_LineSubstring(
					edge_sub_geom,
					ST_LineLocatePoint(prow_sub_geom, ST_ClosestPoint(prow_sub_geom, ST_EndPoint(edge_sub_geom))),
					ST_LineLocatePoint(prow_sub_geom, ST_ClosestPoint(prow_sub_geom, ST_StartPoint(edge_sub_geom)))
				)
			END
		)/ST_Length(prow_sub_geom) AS Length_Fraction_A,
		ST_Length(
			CASE WHEN ST_LineLocatePoint(edge_sub_geom, ST_ClosestPoint(edge_sub_geom, ST_StartPoint(prow_sub_geom))) <
				  ST_LineLocatePoint(edge_sub_geom, ST_ClosestPoint(edge_sub_geom, ST_EndPoint(prow_sub_geom))) 
				THEN ST_LineSubstring(
					edge_sub_geom,
					ST_LineLocatePoint(edge_sub_geom, ST_ClosestPoint(edge_sub_geom, ST_StartPoint(prow_sub_geom))),
					ST_LineLocatePoint(edge_sub_geom, ST_ClosestPoint(edge_sub_geom, ST_EndPoint(prow_sub_geom)))
				)
				ELSE ST_LineSubstring(
					edge_sub_geom,
					ST_LineLocatePoint(edge_sub_geom, ST_ClosestPoint(edge_sub_geom, ST_EndPoint(prow_sub_geom))),
					ST_LineLocatePoint(edge_sub_geom, ST_ClosestPoint(edge_sub_geom, ST_StartPoint(prow_sub_geom)))
				)
			END
		)/ST_Length(edge_sub_geom) AS Length_Fraction_B
	FROM
	(
		SELECT
			*,
			(ST_Dump(ST_CollectionExtract(
				ST_Intersection(
					p.geom,
					ST_Intersection(
						ST_MakeValid(ST_Buffer(p.geom, 100.0, 'endcap=flat join=round')), 
						ST_MakeValid(ST_Buffer(e.edge_geom, 100.0, 'endcap=flat join=round'))
					)
				),
				2
			))).geom AS prow_sub_geom,
			(ST_Dump(ST_CollectionExtract(
				ST_Intersection(
					e.edge_geom,
					ST_Intersection(
						ST_MakeValid(ST_Buffer(p.geom, 100.0, 'endcap=flat join=round')), 
						ST_MakeValid(ST_Buffer(e.edge_geom, 100.0, 'endcap=flat join=round'))
					)
				),
				2
			))).geom AS edge_sub_geom
		FROM
			raw_prow p
		LEFT JOIN
			edge e
		ON
			ST_DWithin( p.geom, e.edge_geom, 25.0 )
		AND
			e.edge_class_id IN (6, 7, 8, 9, 10, 11)
	) AS SB
) AS SA
WHERE
	length_fraction_a > 0.50 AND
	length_fraction_b > 0.50 AND
	hausdorff < 50.0;

SELECT populate_geometry_columns('edge_prow_matching'::regclass); 
