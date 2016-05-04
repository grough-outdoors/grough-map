BEGIN;
ALTER TABLE _tmp_raw_obstructions ADD COLUMN id bigserial;
ALTER TABLE _tmp_raw_obstructions_highway ADD COLUMN id bigserial;
CREATE INDEX "Idx: _tmp_raw_obstructions::geom" ON _tmp_raw_obstructions USING gist (geom);
CREATE INDEX "Idx: _tmp_raw_obstructions_highway::geom" ON _tmp_raw_obstructions_highway USING gist (geom);
COMMIT;

-- Remove anything within a building
DELETE FROM
	_tmp_raw_obstructions
WHERE
	id
IN
(
	SELECT
		A.id AS id
	FROM
		_tmp_raw_obstructions A
	INNER JOIN
		buildings B
	ON
		A.geom && B.building_geom
	AND
		ST_Within(A.geom, B.building_geom)
);

-- Remove dangles by themselves
BEGIN; 
DELETE FROM
	_tmp_raw_obstructions
WHERE
	id
IN
(
	SELECT
		SA.id
	FROM
	(
		SELECT
			A.id AS id,
			B.id AS join_id_start,
			C.id AS join_id_end
		FROM
			_tmp_raw_obstructions A
		LEFT JOIN
			_tmp_raw_obstructions B
		ON
			ST_DWithin(ST_StartPoint(A.geom), B.geom, 3.0)
		AND
			A.id != B.id
		LEFT JOIN
			_tmp_raw_obstructions C
		ON
			ST_DWithin(ST_EndPoint(A.geom), C.geom, 3.0)
		AND
			A.id != C.id
		WHERE
			ST_Length(A.geom) < 25.0
	) SA
	GROUP BY
		SA.id
	HAVING
		Count(SA.join_id_start) < 1 OR Count(SA.join_id_end) < 1
);
COMMIT;

-- Remove dangles which rejoin the original poly
-- TODO

-- Remove the end of polys which are deviating from their lovely straight paths
BEGIN;
UPDATE
	_tmp_raw_obstructions
SET
	geom = geom_replacement
FROM
(
	SELECT
		src_id,
		CASE WHEN abs(deg_start_cap - deg_start_comp) > sub_max_angle AND abs(deg_end_cap - deg_end_comp) > sub_max_angle
		     THEN ST_LineSubstring(geom, sub_cap_length / length, 1.0 - sub_cap_length / length)
		     WHEN abs(deg_start_cap - deg_start_comp) > sub_max_angle
		     THEN ST_LineSubstring(geom, sub_cap_length / length, 1.0)
		     WHEN abs(deg_end_cap - deg_end_comp) > sub_max_angle
		     THEN ST_LineSubstring(geom, 0.0, 1.0 - sub_cap_length / length)
		     ELSE NULL
		END AS geom_replacement
	FROM
	(
		SELECT
			src_id,
			geom,
			sub_cap_length,
			sub_max_angle,
			length,
			degrees(ST_Azimuth(ST_StartPoint(sub_start_cap), ST_EndPoint(sub_start_cap))) AS deg_start_cap,
			degrees(ST_Azimuth(ST_StartPoint(sub_start_comp), ST_EndPoint(sub_start_comp))) AS deg_start_comp,
			degrees(ST_Azimuth(ST_StartPoint(sub_end_cap), ST_EndPoint(sub_end_cap))) AS deg_end_cap,
			degrees(ST_Azimuth(ST_StartPoint(sub_end_comp), ST_EndPoint(sub_end_comp))) AS deg_end_comp
		FROM
		(
			SELECT
				*,
				ST_LineSubstring(geom, 0.0, sub_cap_length / length) AS sub_start_cap,
				ST_LineSubstring(geom, sub_cap_length / length, (sub_cap_length + sub_comp_length) / length) AS sub_start_comp,
				ST_LineSubstring(geom, 1.0 - sub_cap_length / length, 1.0) AS sub_end_cap,
				ST_LineSubstring(geom, 1.0 - (sub_cap_length + sub_comp_length) / length, 1.0 - sub_cap_length / length) AS sub_end_comp
			FROM
			(
				SELECT
					src_id,
					ST_Length(geom) AS length,
					geom,
					25.0 AS sub_max_angle,
					10.0 AS sub_cap_length,
					50.0 AS sub_comp_length
				FROM
					_tmp_raw_obstructions
				WHERE
					ST_Length(geom) > 100.0
			) SA
		) SB
	) SC
) SD
WHERE
	geom_replacement IS NOT NULL
AND
	_tmp_raw_obstructions.src_id = SD.src_id;
COMMIT;

-- Remove entities which overlap with roads and replace them with casings following
-- the actual road alignment
BEGIN;
DROP TABLE IF EXISTS _tmp_raw_obstructions_highway_zones;
CREATE TABLE _tmp_raw_obstructions_highway_zones AS
SELECT
	*,
	ST_Multi(
		ST_CollectionExtract(
			ST_Intersection(
				ST_Difference(
					ST_ExteriorRing(
						(ST_Dump(
							ST_CollectionExtract(
								ST_Buffer(
									h_geom,
									10.0,
									'endcap=flat'
								),
								3
							)
						)).geom
					),
					ST_Buffer(h_geom, 9.0)
				),
				o_zone
			),
			2
		)
	) AS obs_geom
FROM
(
	SELECT
		o_zone_id,
		first(h_geom) AS h_geom,
		first(o_zone) AS o_zone
	FROM
	(
		SELECT
			ROW_NUMBER() OVER () AS o_zone_id,
			*
		FROM
		(
			SELECT
				(ST_Dump(
					ST_Multi(
						ST_CollectionExtract(
							ST_Split(
								o_zone,
								h_geom
							),
							3
						)
					)
				)).geom AS o_zone,
				ST_Multi(
					ST_Intersection(
						h_geom,
						o_zone
					)
				) AS h_geom,
				o_lines
			FROM
			(
				SELECT
					h.id,
					first(h.geom) AS h_geom,
					--ST_Union(ST_Buffer(o.geom, 10.0, 'endcap=flat')) AS o_zone,
					ST_Union(ST_Intersection(ST_Buffer(o.geom, 20.0, 'endcap=flat'), ST_Buffer(h.geom, 10.0, 'endcap=flat'))) AS o_zone,
					ST_Collect(o.geom) AS o_lines
				FROM
					_tmp_raw_obstructions_highway h
				INNER JOIN
					_tmp_raw_obstructions o
				ON
					ST_DWithin(h.geom, o.geom, 20.0)
				AND
					ST_HausdorffDistance(
						ST_Intersection(
							h.geom,
							ST_Buffer(o.geom, 20.0, 'endcap=flat')
						),
						o.geom
					) < 20
				GROUP BY
					h.id
				HAVING
					Count(o.id) > 0
			) SA
		) SB
	) SC
	GROUP BY
		o_zone_id
	HAVING
		ST_Length(ST_Intersection(first(o_lines), first(o_zone))) > 0.2 * ST_Length(first(o_lines))
) SD;
COMMIT;

-- Apply deletion and addition based on road casings
BEGIN;
DROP TABLE IF EXISTS _tmp_raw_obstructions_avoid_casings;
CREATE TABLE
	_tmp_raw_obstructions_avoid_casings
AS
(
	SELECT
		o_id,
		CASE WHEN ST_GeometryType(o_geom) = 'ST_LineString' THEN ST_Multi(o_geom)
		     ELSE ST_Multi(ST_CollectionExtract(o_geom, 2))
		END AS o_geom
	FROM
	(
		SELECT
			o_id,
			ST_Difference(
				o_geom,
				o_zone
			) AS o_geom
		FROM
		(
			SELECT
				o.id AS o_id,
				first(o.geom) AS o_geom,
				ST_Union(z.o_zone) AS o_zone
			FROM
				_tmp_raw_obstructions o
			INNER JOIN
				_tmp_raw_obstructions_highway_zones z
			ON
				o.geom && z.o_zone
			AND
				ST_Intersects(o.geom, z.o_zone)
			GROUP BY
				o.id
		) SA
	) SB
);

DELETE FROM
	_tmp_raw_obstructions
WHERE
	geom IS NULL OR ST_Length(geom) < 1.0;

DELETE FROM
	_tmp_raw_obstructions
WHERE
	id 
IN
	(SELECT o_id FROM _tmp_raw_obstructions_avoid_casings);
	
INSERT INTO 
	_tmp_raw_obstructions
	(geom)
SELECT
	(ST_Dump(obs_geom)).geom
FROM
	_tmp_raw_obstructions_highway_zones;

INSERT INTO 
	_tmp_raw_obstructions
	(geom)
SELECT
	(ST_Dump(o_geom)).geom
FROM
	_tmp_raw_obstructions_avoid_casings;

DROP TABLE IF EXISTS _tmp_raw_obstructions_avoid_casings;
COMMIT;

-- Build joins to self
BEGIN;
CREATE TABLE
	_tmp_raw_obstructions_joins_self
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
	ST_SetSRID(
		CASE WHEN First(recommendedop) = 'Extend' THEN
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
		WHEN First(recommendedop) = 'ExtendEnd' THEN
			ST_MakeLine(First(BaseEnd), First(TargetStart))
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
		     WHEN abs( mod(degrees(ST_Azimuth(BaseEnd, TargetStart))::numeric + 179.99, 180.0) - mod(degrees(ST_Azimuth(SA.BaseStart, SA.BaseEnd))::numeric + 179.99, 180.0) ) < 10.0 AND BaseType='End'
			THEN 'ExtendEnd'
		     WHEN abs( mod(degrees(ST_Azimuth(BaseEnd, TargetStart))::numeric + 179.99, 180.0) - mod(degrees(ST_Azimuth(SA.BaseStart, SA.BaseEnd))::numeric + 179.99, 180.0) ) < 10.0 AND BaseType != 'End'
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
			CASE WHEN ST_Distance(ST_StartPoint(A.geom), B.geom) < ST_Distance(ST_EndPoint(A.geom), B.geom) 
				THEN 'Interp'
				ELSE 'End'
			END AS BaseType,
			CASE WHEN ST_Distance(ST_StartPoint(B.geom), A.geom) < ST_Distance(ST_EndPoint(B.geom), A.geom) 
				THEN ST_StartPoint(B.geom)
				ELSE ST_LineInterpolatePoint(B.geom, (ST_Length(B.geom) - least(10.0, ST_Length(B.geom)))/ST_Length(B.geom))
			END AS TargetStart,
			CASE WHEN ST_Distance(ST_StartPoint(B.geom), A.geom) < ST_Distance(ST_EndPoint(B.geom), A.geom) 
				THEN ST_LineInterpolatePoint(B.geom, least(10.0, ST_Length(B.geom))/ST_Length(B.geom))
				ELSE ST_EndPoint(B.geom)
			END AS TargetEnd
		FROM
			_tmp_raw_obstructions A
		INNER JOIN
			_tmp_raw_obstructions B
		ON
			( ST_DWithin(ST_StartPoint(A.geom), B.geom, 100.0) OR ST_DWithin(ST_EndPoint(A.geom), B.geom, 100.0) )
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
ALTER TABLE _tmp_raw_obstructions_joins_self ADD COLUMN id bigserial;
CREATE INDEX "Idx: _tmp_raw_obstructions_joins_self::geom" ON _tmp_raw_obstructions_joins_self USING gist (geom);
COMMIT;

-- Remove duplicate and inferior joins
DELETE FROM
	_tmp_raw_obstructions_joins_self
WHERE
	id 
IN
(
	SELECT DISTINCT
		id_delete
	FROM
	(
		SELECT
			A.id,
			B.id,
			A.recommendedop,
			B.recommendedop,
			ST_Equals(A.geom, B.geom),
			CASE WHEN ST_Equals(A.geom, B.geom) = true AND A.id > B.id THEN A.id
			     WHEN A.recommendedop = 'Join' AND B.recommendedop = 'Extend' THEN B.id
			     ELSE NULL
			END AS id_delete
		FROM
			_tmp_raw_obstructions_joins_self A
		INNER JOIN
			_tmp_raw_obstructions_joins_self B
		ON
			A.id != B.id
		AND
			A.geom && B.geom
		AND
			ST_DWithin(A.geom, B.geom, 10.0)
		AND
			abs(ST_Length(A.geom) - ST_Length(B.geom)) < 20.0
		AND
			ST_HausdorffDistance(A.geom, B.geom) < 20.0
	) SA
	WHERE
		SA.id_delete IS NOT NULL
);

-- Build joins to highways
BEGIN;
CREATE TABLE
	_tmp_raw_obstructions_joins_highway
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
		CASE WHEN abs( mod(degrees(ST_Azimuth(SA.near1, SA.near2))::numeric + 179.99, 180.0) - mod(degrees(ST_Azimuth(SA.BaseStart, SA.BaseEnd))::numeric + 179.99, 180.0) ) < 10.0
			THEN 'Extend'
		     --WHEN abs( mod(degrees(ST_Azimuth(BaseEnd, TargetStart))::numeric + 179.99, 180.0) - mod(degrees(ST_Azimuth(SA.BaseStart, SA.BaseEnd))::numeric + 179.99, 180.0) ) < 10.0
			--THEN 'Extend'
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
			_tmp_raw_obstructions A
		INNER JOIN
			_tmp_raw_obstructions_highway B
		ON
			( ST_DWithin(ST_StartPoint(A.geom), B.geom, 100.0) OR ST_DWithin(ST_EndPoint(A.geom), B.geom, 100.0) )
		LEFT JOIN
			_tmp_raw_obstructions C
		ON
			( ST_DWithin(ST_StartPoint(A.geom), C.geom, 1.0) OR ST_DWithin(ST_EndPoint(A.geom), C.geom, 1.0) )
		AND
			A.id != C.id
		WHERE
			ST_Length(A.geom) > 2.5
		AND
			C.id IS NULL
	) AS SA
	ORDER BY
		SA.Distance ASC
) AS SB
GROUP BY
	SB.id1, SB.baselocation
HAVING
	First(SB.id2) IS NOT NULL;
ALTER TABLE _tmp_raw_obstructions_joins_highway ADD COLUMN id bigserial;
COMMIT;

-- Apply road casings to extensions too
BEGIN;
UPDATE
	_tmp_raw_obstructions_joins_self
SET
	geom = o_geom
FROM
(
	SELECT
		o_id,
		CASE WHEN ST_GeometryType(o_geom) = 'ST_LineString' THEN o_geom
		     ELSE ST_GeometryN(o_geom, 1)
		END AS o_geom
	FROM
	(
		SELECT
			o_id,
			ST_Difference(
				o_geom,
				o_zone
			) AS o_geom
		FROM
		(
			SELECT
				o.id AS o_id,
				first(o.geom) AS o_geom,
				ST_Union(z.o_zone) AS o_zone
			FROM
				_tmp_raw_obstructions_joins_self o
			INNER JOIN
				_tmp_raw_obstructions_highway_zones z
			ON
				o.geom && z.o_zone
			AND
				ST_Intersects(o.geom, z.o_zone)
			GROUP BY
				o.id
		) SA
	) SB
) SC
WHERE
	id = o_id;

UPDATE
	_tmp_raw_obstructions_joins_highway
SET
	geom = o_geom
FROM
(
	SELECT
		o_id,
		CASE WHEN ST_GeometryType(o_geom) = 'ST_LineString' THEN o_geom
		     ELSE ST_GeometryN(o_geom, 1)
		END AS o_geom
	FROM
	(
		SELECT
			o_id,
			ST_Difference(
				o_geom,
				o_zone
			) AS o_geom
		FROM
		(
			SELECT
				o.id AS o_id,
				first(o.geom) AS o_geom,
				ST_Union(z.o_zone) AS o_zone
			FROM
				_tmp_raw_obstructions_joins_highway o
			INNER JOIN
				_tmp_raw_obstructions_highway_zones z
			ON
				o.geom && z.o_zone
			AND
				ST_Intersects(o.geom, z.o_zone)
			GROUP BY
				o.id
		) SA
	) SB
) SC
WHERE
	id = o_id;

DELETE FROM _tmp_raw_obstructions_joins_self WHERE geom IS NULL OR ST_Length(geom) < 1.0;
DELETE FROM _tmp_raw_obstructions_joins_highway WHERE geom IS NULL OR ST_Length(geom) < 1.0;
COMMIT;

BEGIN;
DELETE FROM _tmp_raw_obstructions_joins_self WHERE ST_GeometryType(geom) != 'ST_LineString'; 
DELETE FROM _tmp_raw_obstructions_joins_highway WHERE ST_GeometryType(geom) != 'ST_LineString'; 
COMMIT;

-- Highway extensions shouldn't be allowed to cross pre-existing obstructions
BEGIN;
DELETE FROM
	_tmp_raw_obstructions_joins_highway
WHERE
	id
IN
(
	SELECT
		j.id
	FROM
		_tmp_raw_obstructions_joins_highway j
	INNER JOIN
		_tmp_raw_obstructions o
	ON ST_Intersects(j.geom, o.geom) AND ST_Crosses(j.geom, o.geom)
);
COMMIT;

-- TODO: Deal with joins which intersect another join (truncate at the join)

SELECT populate_geometry_columns('_tmp_raw_obstructions'::regclass); 
SELECT populate_geometry_columns('_tmp_raw_obstructions_joins_self'::regclass); 
SELECT populate_geometry_columns('_tmp_raw_obstructions_joins_highway'::regclass); 
SELECT populate_geometry_columns('_tmp_raw_obstructions_highway'::regclass); 
SELECT populate_geometry_columns('_tmp_raw_obstructions_highway_zones'::regclass); 
