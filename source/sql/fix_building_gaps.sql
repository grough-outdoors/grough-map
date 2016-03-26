CREATE TABLE import_sv_buildings
AS
SELECT
	gid,
	ST_Buffer( ST_Buffer( geom, 2.0 ), -2.0 ),
	percent_covered_by_osm
FROM
	_import_sv_buildings;
