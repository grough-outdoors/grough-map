DROP TABLE IF EXISTS _tmp_water_surface_reduced;
DROP TABLE IF EXISTS _tmp_watercourse_actions;

CREATE TABLE
	_tmp_water_surface_reduced
AS SELECT
	SD.surface_id,
	SD.surface_reduction,
	SD.surface_new_geom AS surface_geom
FROM
(
	SELECT
		SC.surface_id,
		SC.selected_reduction AS surface_reduction,
		ST_Multi(ST_MakeValid(ST_Buffer(SC.surface_geom, selected_reduction)))::geometry(MultiPolygon, 27700) AS surface_new_geom
	FROM
	(
		SELECT
			surface_id,
			geom_original AS surface_geom,
			CASE WHEN percent_m10 < 0.5 OR area_m10 <= 0 THEN 0.0
			     WHEN percent_m50 < 0.5 OR area_m50 <= 0 THEN -10.0
			     WHEN percent_m100 < 0.5 OR area_m100 <= 0 THEN -50
			     WHEN percent_m200 < 0.5 OR area_m200 <= 0 THEN -100
			     ELSE -200
			END as selected_reduction
		FROM
		(
			SELECT
				surface_id,
				geom_original,
				geom_m10,
				geom_m50,
				geom_m100,
				geom_m200,
				ST_Area(geom_original) AS area_original,
				ST_Area(geom_m10) AS area_m10,
				ST_Area(geom_m50) AS area_m50,
				ST_Area(geom_m100) AS area_m100,
				ST_Area(geom_m200) AS area_m200,
				ST_NumGeometries(geom_original) AS count_original,
				ST_NumGeometries(geom_m10) AS count_m10,
				ST_NumGeometries(geom_m50) AS count_m50,
				ST_NumGeometries(geom_m100) AS count_m100,
				ST_NumGeometries(geom_m200) AS count_m200,
				ST_Area(geom_original) / ST_Area(geom_original) AS percent_original,
				ST_Area(geom_m10) / ST_Area(geom_original) AS percent_m10,
				ST_Area(geom_m50) / ST_Area(geom_original) AS percent_m50,
				ST_Area(geom_m100) / ST_Area(geom_original) AS percent_m100,
				ST_Area(geom_m200) / ST_Area(geom_original) AS percent_m200
			FROM
			(
				SELECT
					surface_id,
					s.surface_geom AS geom_original,
					ST_MakeValid(ST_Buffer(s.surface_geom, -10.0)) AS geom_m10,
					ST_MakeValid(ST_Buffer(s.surface_geom, -50.0)) AS geom_m50,
					ST_MakeValid(ST_Buffer(s.surface_geom, -100.0)) AS geom_m100,
					ST_MakeValid(ST_Buffer(s.surface_geom, -200.0)) AS geom_m200
				FROM
				(
					SELECT
						surface_id,
						surface_class_id,
						ST_Simplify(surface_geom, 10.0) AS surface_geom
					FROM
						surface
					WHERE
						surface_class_id IN (5,6)
				) AS s
				WHERE
					ST_Area(s.surface_geom) > 0
			) SA
		) SB
	) SC
) SD
WHERE
	SD.surface_reduction < 0;

CREATE TABLE
	_tmp_watercourse_actions
AS SELECT
	w.watercourse_id,
	w.watercourse_name,
	s.surface_id,
	CASE WHEN ST_Crosses(w.watercourse_geom, s.surface_geom) THEN 
		CASE WHEN ST_NumGeometries(ST_Intersection(w.watercourse_geom, ST_ExteriorRing(s.surface_geom))) > 1 THEN 'keep-crosses'
		     ELSE 'drop'
		END
	     WHEN ST_Within(w.watercourse_geom, s.surface_geom) THEN 'keep-within'
	END as watercourse_action
FROM
	watercourse w,
	( SELECT surface_id, surface_reduction, (ST_Dump(surface_geom)).geom AS surface_geom FROM _tmp_water_surface_reduced ) s
WHERE
	w.watercourse_geom && s.surface_geom
AND
	ST_Intersects(w.watercourse_geom, s.surface_geom);

DELETE FROM
	watercourse w
WHERE
	w.watercourse_id IN
(
	SELECT
		watercourse_id
	FROM
		_tmp_watercourse_actions a
	WHERE
		a.watercourse_action = 'drop'
);

DROP TABLE _tmp_water_surface_reduced;
DROP TABLE _tmp_watercourse_actions;
