DELETE FROM
	_src_walls
WHERE
	id
IN
(
SELECT
	AA.id
FROM (
	SELECT
		A.id AS id,
		mod(degrees(ST_Azimuth(ST_StartPoint(A.geom), ST_EndPoint(A.geom)))::numeric + 179.99, 360.0) AS ShortAngle,
		mod(degrees(ST_Azimuth(ST_StartPoint(ST_Intersection(B.geom, ST_Buffer(A.geom, 30.0))), ST_EndPoint(ST_Intersection(B.geom, ST_Buffer(A.geom, 30.0)))))::numeric + 179.99, 360.0) AS NearAngle,
		abs(
			mod(degrees(ST_Azimuth(ST_StartPoint(A.geom), ST_EndPoint(A.geom)))::numeric + 180.0, 360.0) -
			mod(degrees(ST_Azimuth(ST_StartPoint(ST_Intersection(B.geom, ST_Buffer(A.geom, 30.0))), ST_EndPoint(ST_Intersection(B.geom, ST_Buffer(A.geom, 30.0)))))::numeric + 180.0, 360.0)
		) AS DiffAngle
	FROM
		_src_walls A
	LEFT JOIN
		_src_walls B
	ON
		ST_DWithin(A.geom, B.geom, 5.0)
	AND
		A.id != B.id
	WHERE
		ST_Length(A.geom) < 25.0
) AA
GROUP BY
	AA.id
HAVING
	min(AA.DiffAngle) > 40.0
OR
	count(AA.DiffAngle) = 0
);
