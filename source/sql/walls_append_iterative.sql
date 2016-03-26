-- Recluster
REINDEX TABLE _src_walls;

-- Identify adjoining T90 which will connect to the START
INSERT INTO _src_walls (geom, base, unclean_id)
SELECT
	ST_LineMerge(
		ST_Collect(
			A.NewLine,
			ST_MakeLine(ST_StartPoint(A.BaseLine), ST_ClosestPoint(A.NewLine, A.BaseLine))
		)
	),
	false,
	JoinID
FROM
(
SELECT
	-- Fetch only a section of wall which joins
	ST_LineSubstring(
		WallJoin.geom, 
		CASE WHEN ST_LineLocatePoint(WallJoin.geom, ST_ClosestPoint(WallJoin.geom, WallBase.geom)) > 0.0
			THEN 0.0
			ELSE ST_LineLocatePoint(WallJoin.geom, ST_ClosestPoint(WallJoin.geom, WallBase.geom))
		END, 
		CASE WHEN  ST_LineLocatePoint(WallJoin.geom, ST_ClosestPoint(WallJoin.geom, WallBase.geom)) > 0.0
			THEN ST_LineLocatePoint(WallJoin.geom, ST_ClosestPoint(WallJoin.geom, WallBase.geom))
			ELSE 1.0
		END
	) AS NewLine,
	WallBase.geom AS BaseLine,
	WallJoin.id AS JoinID
FROM
	_src_walls WallBase
INNER JOIN
	_src_walls_unclean WallJoin
ON
	WallJoin.id != WallBase.unclean_id
AND
	WallJoin.threshold = 90
AND
	ST_DWithin(ST_StartPoint(WallBase.geom), WallJoin.geom, 7.0)
AND
	-- Start must be nearer than the end (otherwise should be joining the other way)
	ST_Distance(ST_StartPoint(WallBase.geom), WallJoin.geom) <
	ST_Distance(ST_EndPoint(WallBase.geom), WallJoin.geom)
AND
	ST_Length(WallJoin.geom) > 9.0
) AS A
WHERE
	ST_Length(A.NewLine) > 9.0
AND
	ST_GeometryType(
		ST_LineMerge(
			ST_Collect(
				A.NewLine,
				ST_MakeLine(ST_StartPoint(A.BaseLine), ST_ClosestPoint(A.NewLine, A.BaseLine))
			)
		)
	) = 'ST_LineString';

-- Identify adjoining T90 which will connect to the END
INSERT INTO _src_walls (geom, base, unclean_id)
SELECT
	ST_LineMerge(
		ST_Collect(
			A.NewLine,
			ST_MakeLine(ST_EndPoint(A.BaseLine), ST_ClosestPoint(A.NewLine, A.BaseLine))
		)
	),
	false,
	JoinID
FROM
(
SELECT
	-- Fetch only a section of wall which joins
	ST_LineSubstring(
		WallJoin.geom, 
		CASE WHEN ST_LineLocatePoint(WallJoin.geom, ST_ClosestPoint(WallJoin.geom, WallBase.geom)) > 0.0
			THEN 0.0
			ELSE ST_LineLocatePoint(WallJoin.geom, ST_ClosestPoint(WallJoin.geom, WallBase.geom))
		END, 
		CASE WHEN  ST_LineLocatePoint(WallJoin.geom, ST_ClosestPoint(WallJoin.geom, WallBase.geom)) > 0.0
			THEN ST_LineLocatePoint(WallJoin.geom, ST_ClosestPoint(WallJoin.geom, WallBase.geom))
			ELSE 1.0
		END
	) AS NewLine,
	WallBase.geom AS BaseLine,
	WallJoin.id AS JoinID
FROM
	_src_walls WallBase
INNER JOIN
	_src_walls_unclean WallJoin
ON
	WallJoin.id != WallBase.unclean_id
AND
	WallJoin.threshold = 90
AND
	ST_DWithin(ST_EndPoint(WallBase.geom), WallJoin.geom, 7.0)
AND
	-- Start must be nearer than the end (otherwise should be joining the other way)
	ST_Distance(ST_EndPoint(WallBase.geom), WallJoin.geom) <
	ST_Distance(ST_StartPoint(WallBase.geom), WallJoin.geom)
AND
	ST_Length(WallJoin.geom) > 9.0
) AS A
WHERE
	ST_Length(A.NewLine) > 9.0
AND
	ST_GeometryType(
		ST_LineMerge(
			ST_Collect(
				A.NewLine,
				ST_MakeLine(ST_StartPoint(A.BaseLine), ST_ClosestPoint(A.NewLine, A.BaseLine))
			)
		)
	) = 'ST_LineString';

-- Remove duplicates
DELETE FROM _src_walls
WHERE id IN (
	SELECT id
        FROM (
		SELECT id, ROW_NUMBER() OVER (
			partition BY unclean_id ORDER BY id
		) AS rnum
                FROM _src_walls) t
	WHERE t.rnum > 1);