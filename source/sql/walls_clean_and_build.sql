--TRUNCATE TABLE _src_walls;

DROP TABLE IF EXISTS _src_walls_unclean;
DROP TABLE IF EXISTS _src_walls;

CREATE TABLE _src_walls_unclean (
  id bigserial,
  geom geometry(LineString,27700),
  threshold integer
);

CREATE TABLE _src_walls (
  id bigserial,
  unclean_id bigint,
  base boolean,
  geom geometry(LineString,27700)
);

-- Add spatial indices
DROP INDEX IF EXISTS "_src_walls_unclean::geom";
CREATE INDEX "_src_walls_unclean::geom"
  ON public._src_walls_unclean
  USING gist
  (geom);
ALTER TABLE public._src_walls_unclean CLUSTER ON "_src_walls_unclean::geom";

DROP INDEX IF EXISTS "_src_walls_unclean::threshold";
CREATE INDEX "_src_walls_unclean::threshold"
   ON public._src_walls_unclean USING btree (threshold ASC NULLS LAST);

DROP INDEX IF EXISTS "_src_walls_unclean::id";
CREATE INDEX "_src_walls_unclean::id"
  ON public._src_walls_unclean USING btree (id);

ALTER TABLE public._src_walls_unclean
   ADD CONSTRAINT "PKEY: _src_walls_unclean::id" PRIMARY KEY (id);

ALTER TABLE public._src_walls
  ADD CONSTRAINT "PKEY: _src_walls::id" PRIMARY KEY(id);

DROP INDEX IF EXISTS "_src_walls::geom";
CREATE INDEX "_src_walls::geom"
  ON public._src_walls
  USING gist
  (geom);
ALTER TABLE public._src_walls CLUSTER ON "_src_walls::geom";

DROP INDEX IF EXISTS "_src_walls::unclean_id";
CREATE INDEX "_src_walls::unclean_id"
   ON public._src_walls USING btree (unclean_id ASC NULLS LAST);

DROP INDEX IF EXISTS "_src_walls_t200::geom";
CREATE INDEX "_src_walls_t200::geom"
  ON public._src_walls_t200
  USING gist
  (geom);
ALTER TABLE public._src_walls_t200 CLUSTER ON "_src_walls_t200::geom";

DROP INDEX IF EXISTS "_src_walls_t90::geom";
CREATE INDEX "_src_walls_t90::geom"
  ON public._src_walls_t90
  USING gist
  (geom);
ALTER TABLE public._src_walls_t90 CLUSTER ON "_src_walls_t90::geom";

DROP INDEX IF EXISTS "_src_walls_t40::geom";
CREATE INDEX "_src_walls_t40::geom"
  ON public._src_walls_t40
  USING gist
  (geom);
ALTER TABLE public._src_walls_t40 CLUSTER ON "_src_walls_t40::geom";

-- Add T200s which have a T90 followiung a similar path
INSERT INTO _src_walls_unclean (geom, threshold)
SELECT T200.geom, 200 FROM _src_walls_t200 T200
LEFT JOIN _src_walls_t90 T90
ON ST_DWithin(T90.geom, T200.geom, 5)
AND ST_HausdorffDistance(ST_Intersection(T90.geom, ST_Intersection(ST_Buffer(T200.geom, 5.0, 'endcap=flat join=round'), ST_Buffer(T90.geom, 5.0, 'endcap=flat join=round'))), ST_Intersection(T200.geom, ST_Intersection(ST_Buffer(T200.geom, 5.0, 'endcap=flat join=round'), ST_Buffer(T90.geom, 5.0, 'endcap=flat join=round')))) < 5.0
GROUP BY T200.geom
HAVING Count(T90.gid) > 0;

-- Add any non-overlapping T90s
INSERT INTO _src_walls_unclean (geom, threshold)
SELECT
	simple.geom,
	simple.threshold
FROM
(
	SELECT 
		(ST_Dump(
			CASE WHEN Count(tHigher.geom) > 0 THEN
				ST_Intersection(
					t90.geom,
					ST_SymDifference(ST_MakeValid(ST_Buffer(t90.geom, 4.5, 'endcap=flat join=round')), ST_MakeValid(ST_Buffer(ST_Union(tHigher.geom), 4.5, 'endcap=flat join=round')))
				)
			ELSE
				t90.geom
			END
		)).geom AS geom,
		90 AS threshold
	FROM 
		_src_walls_t90 t90
	LEFT JOIN
		_src_walls_unclean tHigher 
	ON
		ST_DWithin(t90.geom, tHigher.geom, 4.5)
	GROUP BY
		t90.geom
) AS simple
WHERE
	ST_GeometryType(simple.geom) = 'ST_LineString';

-- Add any non-overlapping T40s
INSERT INTO _src_walls_unclean (geom, threshold)
SELECT
	simple.geom,
	simple.threshold
FROM
(
	SELECT 
		(ST_Dump(
			CASE WHEN Count(tHigher.geom) > 0 THEN
				ST_Intersection(
					t40.geom,
					ST_SymDifference(ST_MakeValid(ST_Buffer(t40.geom, 4.5, 'endcap=flat join=round')), ST_MakeValid(ST_Buffer(ST_Union(tHigher.geom), 4.5, 'endcap=flat join=round')))
				)
			ELSE
				t40.geom
			END
		)).geom AS geom,
		40 AS threshold
	FROM 
		_src_walls_t40 t40
	LEFT JOIN
		_src_walls_unclean tHigher 
	ON
		ST_DWithin(t40.geom, tHigher.geom, 4.5)
	GROUP BY
		t40.geom
) AS simple
WHERE
	ST_GeometryType(simple.geom) = 'ST_LineString';

UPDATE _src_walls_unclean SET geom=ST_SnapToGrid(ST_Simplify(geom, 1.0), 1.0);
UPDATE _src_walls_unclean SET geom=ST_Simplify(geom, 5.0);

--- Add the T200 walls as a base
INSERT INTO _src_walls (geom, base, unclean_id)
SELECT
	geom,
	true,
	T200.id
FROM
	_src_walls_unclean T200
WHERE
	threshold=200;

-- Add T90s which have a T40 followiung a similar path
INSERT INTO _src_walls (geom, base, unclean_id)
SELECT
	T90.geom,
	true,
	T90.id
FROM
	_src_walls_unclean T90
INNER JOIN 
	_src_walls_t40 T40
ON
	T90.threshold = 90
AND
	ST_DWithin(T40.geom, T90.geom, 5)
AND 
	ST_HausdorffDistance(ST_Intersection(T40.geom, ST_Buffer(T90.geom, 5.0, 'endcap=flat join=round')), T90.geom) < 5.0
GROUP BY 
	T90.geom, T90.id
HAVING
	Count(T40.gid) > 0
AND
	ST_GeometryType(T90.geom) = 'ST_LineString';
