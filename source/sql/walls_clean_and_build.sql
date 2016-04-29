/*
DROP TABLE IF EXISTS _src_obstructions_unclean;
DROP TABLE IF EXISTS _src_obstructions;

CREATE TABLE _src_obstructions_unclean (
  id bigserial,
  geom geometry(MultiLineString,27700),
  threshold integer
);

CREATE TABLE _src_obstructions (
  id bigserial,
  unclean_id bigint,
  base boolean,
  geom geometry(LineString,27700)
);

-- Add spatial indices
DROP INDEX IF EXISTS "_src_obstructions_unclean::geom";
CREATE INDEX "_src_obstructions_unclean::geom"
  ON public._src_obstructions_unclean
  USING gist
  (geom);
ALTER TABLE public._src_obstructions_unclean CLUSTER ON "_src_obstructions_unclean::geom";

DROP INDEX IF EXISTS "_src_obstructions_unclean::threshold";
CREATE INDEX "_src_obstructions_unclean::threshold"
   ON public._src_obstructions_unclean USING btree (threshold ASC NULLS LAST);

DROP INDEX IF EXISTS "_src_obstructions_unclean::id";
CREATE INDEX "_src_obstructions_unclean::id"
  ON public._src_obstructions_unclean USING btree (id);

ALTER TABLE public._src_obstructions_unclean
   ADD CONSTRAINT "PKEY: _src_obstructions_unclean::id" PRIMARY KEY (id);

ALTER TABLE public._src_obstructions
  ADD CONSTRAINT "PKEY: _src_obstructions::id" PRIMARY KEY(id);

DROP INDEX IF EXISTS "_src_obstructions::geom";
CREATE INDEX "_src_obstructions::geom"
  ON public._src_obstructions
  USING gist
  (geom);
ALTER TABLE public._src_obstructions CLUSTER ON "_src_obstructions::geom";
*/

TRUNCATE TABLE _src_obstructions_unclean;
INSERT INTO _src_obstructions_unclean (geom, threshold)
SELECT
	ST_Multi(
		ST_CollectionExtract(
			ST_Collect(
				ST_Difference(
					T1.geom,
					CASE WHEN Count(T3.gid) > 0
					     THEN ST_Union(
							ST_Union(ST_Buffer(T2.geom, 5.0, 'endcap=square')),
							ST_Union(ST_Buffer(T3.geom, 5.0, 'endcap=square'))
						)
					     ELSE ST_Union(ST_Buffer(T2.geom, 5.0, 'endcap=flat'))
					END
				),
				CASE WHEN Count(T3.gid) > 0 
				     THEN ST_Collect(
						ST_Difference(
							ST_Union(T2.geom),
							ST_Union(ST_Buffer(T3.geom, 5.0, 'endcap=square'))
						),
						ST_Union(T3.geom)
					)
				     ELSE ST_Union(T2.geom)
				END
			),
			2
		)
	),
	0
FROM
	_src_obstructions_lev1 T1
LEFT JOIN
	_src_obstructions_lev2 T2
ON
	ST_DWithin(T1.geom, T2.geom, 10)
AND
	ST_Length(
		ST_Intersection(
			T2.geom,
			ST_Buffer(T1.geom, 5.0, 'endcap=flat')
		)
	) > least(ST_Length(T1.geom), ST_Length(T2.geom) * 0.2)
AND
	ST_HausdorffDistance(
		ST_Intersection(
			T1.geom,
			ST_Buffer(T2.geom, 5.0, 'endcap=flat')
		),
		ST_Intersection(
			T2.geom,
			ST_Buffer(T1.geom, 5.0, 'endcap=flat')
		)
	) < ST_Length(T2.geom)
LEFT JOIN
	_src_obstructions_lev3 T3
ON
	ST_DWithin(T2.geom, T3.geom, 10)
AND
	ST_Length(
		ST_Intersection(
			T3.geom,
			ST_Buffer(T2.geom, 5.0, 'endcap=flat')
		)
	) > least(ST_Length(T2.geom), ST_Length(T3.geom) * 0.2)
AND
	ST_HausdorffDistance(
		ST_Intersection(
			T2.geom,
			ST_Buffer(T3.geom, 5.0, 'endcap=flat')
		),
		ST_Intersection(
			T3.geom,
			ST_Buffer(T2.geom, 5.0, 'endcap=flat')
		)
	) < ST_Length(T3.geom)
WHERE
	ST_Length(T1.geom) > 10.0
GROUP BY
	T1.gid
HAVING
	Count(T2.gid) > 0
OR
	Count(T3.gid) > 0;

-- Remove crazy geoms that are in effect doubling back on themselves
DELETE FROM
	_src_obstructions_unclean
WHERE
	ST_Length(geom) > CASE WHEN ST_GeometryType(ST_ConvexHull(geom)) = 'ST_Polygon'
		THEN ST_Length(ST_ExteriorRing(ST_ConvexHull(geom)))
		ELSE ST_Length(geom)
	END;

-- Remove duplicates
DELETE FROM
	_src_obstructions_unclean
WHERE
	id
IN
(
	SELECT
		o2.id
	FROM
		_src_obstructions_unclean o1
	INNER JOIN
		_src_obstructions_unclean o2
	ON
		o1.id != o2.id
	AND
		o1.id < o2.id
	AND
		ST_Equals(o1.geom, o2.geom)
);

/*
-- Remove anything that doesn't seem like a linear feature
-- TODO: This is causing problems and removing some features it shouldn't
DELETE FROM
	_src_obstructions_unclean
WHERE
	ST_GeometryType(ST_ConvexHull(geom)) LIKE '%Polygon' 
AND
	ST_Length(ST_ExteriorRing(ST_ConvexHull(geom))) / ST_Length(geom) < 2.0;
*/

/* OLD STUFF BELOW */

/*
-- Add T3s which have a T2 followiung a similar path
INSERT INTO _src_obstructions_unclean (geom, threshold)
SELECT 
	T3.geom, 
	3 
FROM 
	_src_obstructions_lev3 T3
LEFT JOIN 
	_src_obstructions_lev2 T2
ON 
	ST_DWithin(T2.geom, T3.geom, 10)
AND 
	ST_HausdorffDistance(
		ST_Intersection(
			T2.geom, 
			ST_Intersection(ST_Buffer(T3.geom, 5.0, 'endcap=flat join=round'), ST_Buffer(T2.geom, 5.0, 'endcap=flat join=round'))
		),
		ST_Intersection(
			T3.geom, 
			ST_Intersection(ST_Buffer(T3.geom, 5.0, 'endcap=flat join=round'), ST_Buffer(T2.geom, 5.0, 'endcap=flat join=round'))
		)
	) < 5.0
GROUP BY 
	T3.geom
HAVING 
	Count(T2.gid) > 0;

-- Add any non-overlapping T2s
INSERT INTO _src_obstructions_unclean (geom, threshold)
SELECT
	simple.geom,
	simple.threshold
FROM
(
	SELECT 
		(ST_Dump(
			CASE WHEN Count(tHigher.geom) > 0 THEN
				ST_Intersection(
					t2.geom,
					ST_SymDifference(ST_MakeValid(ST_Buffer(t2.geom, 4.5, 'endcap=flat join=round')), ST_MakeValid(ST_Buffer(ST_Union(tHigher.geom), 4.5, 'endcap=flat join=round')))
				)
			ELSE
				t2.geom
			END
		)).geom AS geom,
		2 AS threshold
	FROM 
		_src_obstructions_lev2 t2
	LEFT JOIN
		_src_obstructions_unclean tHigher 
	ON
		ST_DWithin(t2.geom, tHigher.geom, 4.5)
	GROUP BY
		t2.geom
) AS simple
WHERE
	ST_GeometryType(simple.geom) = 'ST_LineString';

-- Add any non-overlapping T1s
INSERT INTO _src_obstructions_unclean (geom, threshold)
SELECT
	simple.geom,
	simple.threshold
FROM
(
	SELECT 
		(ST_Dump(
			CASE WHEN Count(tHigher.geom) > 0 THEN
				ST_Intersection(
					t1.geom,
					ST_SymDifference(ST_MakeValid(ST_Buffer(t1.geom, 4.5, 'endcap=flat join=round')), ST_MakeValid(ST_Buffer(ST_Union(tHigher.geom), 4.5, 'endcap=flat join=round')))
				)
			ELSE
				t1.geom
			END
		)).geom AS geom,
		1 AS threshold
	FROM 
		_src_obstructions_lev1 t1
	LEFT JOIN
		_src_obstructions_unclean tHigher 
	ON
		ST_DWithin(t1.geom, tHigher.geom, 4.5)
	GROUP BY
		t1.geom
) AS simple
WHERE
	ST_GeometryType(simple.geom) = 'ST_LineString';

UPDATE _src_obstructions_unclean SET geom=ST_SnapToGrid(ST_Simplify(geom, 1.0), 1.0);
UPDATE _src_obstructions_unclean SET geom=ST_Simplify(geom, 5.0);

--- Add the T3 walls as a base
INSERT INTO _src_obstructions (geom, base, unclean_id)
SELECT
	geom,
	true,
	T3.id
FROM
	_src_obstructions_unclean T3
WHERE
	threshold=3;

-- Add T2s which have a T1 followiung a similar path
INSERT INTO _src_obstructions (geom, base, unclean_id)
SELECT
	T2.geom,
	true,
	T2.id
FROM
	_src_obstructions_unclean T2
INNER JOIN 
	_src_obstructions_lev1 T1
ON
	T2.threshold = 2
AND
	ST_DWithin(T1.geom, T2.geom, 5)
AND 
	ST_HausdorffDistance(ST_Intersection(T1.geom, ST_Buffer(T2.geom, 5.0, 'endcap=flat join=round')), T2.geom) < 5.0
GROUP BY 
	T2.geom, T2.id
HAVING
	Count(T1.gid) > 0
AND
	ST_GeometryType(T2.geom) = 'ST_LineString';
*/