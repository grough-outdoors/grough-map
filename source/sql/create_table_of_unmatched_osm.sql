CREATE TABLE
	import_osm_highways_unmatched
AS
SELECT
	o.*
FROM
	import_osm_highways o
LEFT JOIN
	_import_vmd_osm_matches m
ON
	o.osm_id = m.osm_id
WHERE
	m.osm_id IS NULL;