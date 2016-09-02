BEGIN;
UPDATE 
	_src_os_opmplc_building 
SET 
	geom=ST_GeometryN(ST_Multi(ST_MakeValid(geom)), 1);
COMMIT;

BEGIN;
INSERT INTO
	buildings
(
	building_geom_source,
	building_geom_source_id,
	building_geom,
	building_layer
)
SELECT
	'OML',
	gid,
	ST_Multi(geom),
	0::integer
FROM
	_src_os_opmplc_building
WHERE
	gid 
IN
(
	SELECT DISTINCT
		gid
	FROM
	(
		SELECT
			gid,
			geom,
			ST_CollectionExtract(ST_Multi(ST_Union(ST_Buffer(ST_MakeValid(building_geom), 0.25))), 3) AS building_geom
		FROM
			_src_os_opmplc_building
		LEFT JOIN
			buildings b
		ON
			b.building_geom && geom
		AND
			ST_Intersects(b.building_geom, geom)
		WHERE
			gid
		IN
		(
			SELECT
				gid
			FROM
			(
				SELECT
					o.gid,
					ST_MakeValid(ST_SnapToGrid(first(o.geom), 0.25)) AS geom,
					ST_Union(ST_Buffer(ST_MakeValid(building_geom), 0.25)) AS match_geom
				FROM
					_src_os_opmplc_building o
				LEFT JOIN
					buildings b
				ON
					o.geom && b.building_geom
				AND
					ST_Intersects(b.building_geom, o.geom)
				WHERE
				(
					b.building_id IS NULL
				OR
					abs(ST_XMax(building_geom) - ST_XMax(geom)) > 100.0
				OR
					abs(ST_YMax(building_geom) - ST_YMax(geom)) > 100.0
				OR
					abs(ST_XMin(building_geom) - ST_XMin(geom)) > 100.0
				OR
					abs(ST_YMin(building_geom) - ST_YMin(geom)) > 100.0
				)
				AND
					ST_Area(o.geom) > 50 * 50
				GROUP BY
					o.gid
			) SA
			WHERE
				(
					abs(ST_XMax(match_geom) - ST_XMax(geom)) > 100.0
				OR
					abs(ST_YMax(match_geom) - ST_YMax(geom)) > 100.0
				OR
					abs(ST_XMin(match_geom) - ST_XMin(geom)) > 100.0
				OR
					abs(ST_YMin(match_geom) - ST_YMin(geom)) > 100.0
				)
			AND
				ST_Area(ST_Intersection(ST_MakeValid(ST_Buffer(geom, 0.25)), ST_MakeValid(ST_Buffer(match_geom, 0.25)))) / ST_Area(geom) < 0.5
		)
		GROUP BY
			gid
	) SB
	WHERE
		ST_Area(ST_Intersection(ST_MakeValid(ST_Buffer(building_geom, 0.25)), ST_MakeValid(ST_Buffer(geom, 0.25)))) < 0.5 * ST_Area(geom)
);
COMMIT;
