DROP TABLE IF EXISTS _src_obstructions_joins;
CREATE TABLE
	_src_obstructions_joins
AS
SELECT
	First(id1) AS ID1,
	First(id2) AS ID2,
	First(geom1) AS BaseLine,
	First(geom2) AS TargetLine,
	First(baselocation) AS BaseLocation,
	First(near1) AS Near1,
	First(near2) AS Near2,
	First(distance) AS Distance,
	First(directbearing) AS DirectBearing,
	First(targetbearing) AS TargetBearing,
	First(basebearing) AS BaseBearing,
	First(similaritydiff) AS SimilarityDiff,
	First(continuationdiff) AS ContinuationDiff,
	First(recommendedop) AS RecommendedOp,
	First(extendline) AS ExtendLine,
	ST_SetSRID(CASE WHEN First(recommendedop) = 'Extend' THEN
		CASE WHEN ST_GeometryType(ST_Intersection(First(extendline),First(geom2))) = 'ST_Point' THEN
			ST_LineSubstring(
				First(extendline),
				0.0,
				ST_LineLocatePoint(
					First(extendline),
					ST_Intersection(
						First(extendline),
						First(geom2)
					)
				)
			)
		ELSE
			ST_MakeLine(First(near1), First(near2))
		END
		WHEN First(recommendedop) = 'Join' THEN
			ST_MakeLine(First(near1), First(near2))
		ELSE NULL
	END, 27700) AS geom
FROM
(
	SELECT
		*,
		mod(degrees(ST_Azimuth(SA.near1, SA.near2))::numeric + 179.99, 180.0) AS DirectBearing,
		mod(degrees(ST_Azimuth(SA.TargetStart, SA.TargetEnd))::numeric + 179.99, 180.0) AS TargetBearing,
		mod(degrees(ST_Azimuth(SA.BaseStart, SA.BaseEnd))::numeric + 179.99, 180.0) AS BaseBearing,
		abs(
			mod(degrees(ST_Azimuth(SA.near1, SA.near2))::numeric + 179.99, 180.0) -
			mod(degrees(ST_Azimuth(SA.TargetStart, SA.TargetEnd))::numeric + 179.99, 180.0)
		) AS SimilarityDiff,
		abs(
			mod(degrees(ST_Azimuth(SA.near1, SA.near2))::numeric + 179.99, 180.0) -
			mod(degrees(ST_Azimuth(SA.BaseStart, SA.BaseEnd))::numeric + 179.99, 180.0)
		) AS ContinuationDiff,
		CASE WHEN abs( mod(degrees(ST_Azimuth(SA.near1, SA.near2))::numeric + 179.99, 180.0) - mod(degrees(ST_Azimuth(SA.TargetStart, SA.TargetEnd))::numeric + 179.99, 180.0) ) < 10.0 
			THEN 'Join'
		     WHEN abs( mod(degrees(ST_Azimuth(SA.near1, SA.near2))::numeric + 179.99, 180.0) - mod(degrees(ST_Azimuth(SA.BaseStart, SA.BaseEnd))::numeric + 179.99, 180.0) ) < 10.0
			THEN 'Extend'
		     WHEN abs( mod(degrees(ST_Azimuth(BaseEnd, TargetStart))::numeric + 179.99, 180.0) - mod(degrees(ST_Azimuth(SA.BaseStart, SA.BaseEnd))::numeric + 179.99, 180.0) ) < 10.0
			THEN 'Extend'
		ELSE 'Ignore'
		END AS RecommendedOp,
		CASE WHEN BaseLocation='Start' THEN
			ST_MakeLine(BaseStart, ST_Translate(BaseStart, sin(ST_Azimuth(BaseStart, BaseEnd)) * -100.0, cos(ST_Azimuth(BaseStart, BaseEnd)) * -100.0))
		     ELSE 
			ST_MakeLine(BaseEnd, ST_Translate(BaseStart, sin(ST_Azimuth(BaseStart, BaseEnd)) * 100.0, cos(ST_Azimuth(BaseStart, BaseEnd)) * 100.0))
		END AS ExtendLine
	FROM
	(
		SELECT
			A.id AS id1,
			B.id AS id2,
			A.geom AS geom1,
			B.geom AS geom2,
			ST_ClosestPoint(A.geom, B.geom) AS near1,
			ST_ClosestPoint(B.geom, A.geom) AS near2,
			CASE WHEN ST_Distance(ST_StartPoint(A.geom), B.geom) < ST_Distance(ST_EndPoint(A.geom), B.geom) 
				THEN ST_Distance(ST_StartPoint(A.geom), B.geom)
				ELSE ST_Distance(ST_EndPoint(A.geom), B.geom)
			END AS Distance,
			CASE WHEN ST_Distance(ST_StartPoint(A.geom), B.geom) < ST_Distance(ST_EndPoint(A.geom), B.geom) 
				THEN 'Start'
				ELSE 'End'
			END AS BaseLocation,
			CASE WHEN ST_Distance(ST_StartPoint(A.geom), B.geom) < ST_Distance(ST_EndPoint(A.geom), B.geom) 
				THEN ST_StartPoint(A.geom)
				ELSE ST_LineInterpolatePoint(A.geom, (ST_Length(A.geom) - least(10.0, ST_Length(A.geom)))/ST_Length(A.geom))
			END AS BaseStart,
			CASE WHEN ST_Distance(ST_StartPoint(A.geom), B.geom) < ST_Distance(ST_EndPoint(A.geom), B.geom) 
				THEN ST_LineInterpolatePoint(A.geom, least(10.0, ST_Length(A.geom))/ST_Length(A.geom))
				ELSE ST_EndPoint(A.geom)
			END AS BaseEnd,
			CASE WHEN ST_Distance(ST_StartPoint(B.geom), A.geom) < ST_Distance(ST_EndPoint(B.geom), A.geom) 
				THEN ST_StartPoint(B.geom)
				ELSE ST_LineInterpolatePoint(B.geom, (ST_Length(B.geom) - least(10.0, ST_Length(B.geom)))/ST_Length(B.geom))
			END AS TargetStart,
			CASE WHEN ST_Distance(ST_StartPoint(B.geom), A.geom) < ST_Distance(ST_EndPoint(B.geom), A.geom) 
				THEN ST_LineInterpolatePoint(B.geom, least(10.0, ST_Length(B.geom))/ST_Length(B.geom))
				ELSE ST_EndPoint(B.geom)
			END AS TargetEnd
		FROM
			_src_obstructions A
		INNER JOIN
			_src_obstructions B
		ON
			( ST_DWithin(ST_StartPoint(A.geom), B.geom, 75.0) OR ST_DWithin(ST_EndPoint(A.geom), B.geom, 75.0) )
		AND
			A.id != B.id
		WHERE
			ST_Length(A.geom) > 2.5
		AND
			ST_Length(B.geom) > 2.5
	) AS SA
	ORDER BY
		SA.Distance ASC
) AS SB
GROUP BY
	SB.id1, SB.baselocation
HAVING
	First(SB.id2) IS NOT NULL;

DELETE FROM
	_src_obstructions_joins
WHERE
	ST_GeometryType(geom) != 'ST_LineString';

DROP INDEX IF EXISTS "_src_obstructions_joins::geom";
CREATE INDEX "_src_obstructions_joins::geom"
  ON public._src_obstructions_joins
  USING gist
  (geom);
ALTER TABLE public._src_obstructions_joins CLUSTER ON "_src_obstructions_joins::geom";

INSERT INTO _src_obstructions (geom, base, unclean_id)
SELECT
	NewGeom,
	false,
	NULL
FROM
(
	SELECT
		geom AS NewGeom
	FROM
		_src_obstructions_joins
) AS SA;
