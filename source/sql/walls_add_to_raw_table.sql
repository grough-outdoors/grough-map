DROP TABLE IF EXISTS _tmp_obstructions_joined;
CREATE TABLE _tmp_obstructions_joined AS
SELECT
	zone_id AS obs_id,
	(ST_Dump(obstruction_geom)).geom AS obs_geom
FROM
(
	SELECT
		zone_id,
		ST_Multi(ST_Simplify(ST_LineMerge(ST_Multi(ST_CollectionExtract(ST_Collect(o.geom), 2))), 5.0)) AS obstruction_geom
	FROM
	(
		SELECT
			ROW_NUMBER() OVER () AS zone_id,
			zone_geom
		FROM
		(
			SELECT
				(ST_Dump(zone_geom)).geom AS zone_geom
			FROM
			(
				SELECT
					ST_Union(ST_Buffer(geom, 10.0)) AS zone_geom
				FROM
					_tmp_obstructions
				GROUP BY
					true
			) SA
		) SB
	) SC
	LEFT JOIN
		_tmp_obstructions o
	ON
		ST_Intersects(o.geom, SC.zone_geom)
	GROUP BY
		zone_id
) SD;

DELETE FROM _tmp_obstructions_joined WHERE ST_Length(obs_geom) < 5.0;

INSERT INTO raw_obstructions (obs_geom) 
	SELECT ST_Multi(obs_geom) FROM _tmp_obstructions_joined;

DROP TABLE IF EXISTS _tmp_obstructions_joined;
