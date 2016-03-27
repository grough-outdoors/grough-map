INSERT INTO
	buildings
(
	building_geom_source,
	building_geom_source_id,
	building_geom,
	building_layer
)
SELECT
	'OML' AS building_geom_source,
	SA.gid AS building_geom_source_id,
	ST_Multi(SA.missing_geom) AS building_geom,
	0::integer AS building_layer
FROM (
	SELECT
		o.gid,
		(ST_Dump(ST_MakeValid(ST_Difference(ST_Multi(ST_MakeValid(o.geom)), existing.existing_geom)))).geom AS missing_geom
	FROM
		_src_os_opmplc_building o
	LEFT JOIN (
		SELECT
			o.gid,
			ST_Union(b.building_geom) AS existing_geom
		FROM
			_src_os_opmplc_building o
		LEFT JOIN
			buildings b
		ON
			o.geom && b.building_geom
		AND
			ST_Intersects(o.geom, b.building_geom)
		GROUP BY
			o.gid
	) existing
	ON
		o.gid = existing.gid
) SA
WHERE
	ST_Area(SA.missing_geom) > 300
AND
	( ST_Area(SA.missing_geom) > ST_Perimeter(SA.missing_geom) * 2.5 OR ST_Area(SA.missing_geom) > 2000 );

UPDATE
	buildings
SET
	building_layer = 0
WHERE
	building_layer IS NULL;
	