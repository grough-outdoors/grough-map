CREATE TABLE
	_import_names_test_populated_places
AS
SELECT
	"NAME1" AS place_name,
	ST_SetSRID( ST_MakePoint( "GEOMETRY_X", "GEOMETRY_Y" ), 27700 ) AS place_point,
	ST_SetSRID( ST_MakeBox2D( ST_MakePoint( "MBR_XMIN", "MBR_YMIN" ), ST_MakePoint( "MBR_XMAX", "MBR_YMAX" ) ), 27700 ) AS place_bbox,
	ST_Area( ST_SetSRID( ST_MakeBox2D( ST_MakePoint( "MBR_XMIN", "MBR_YMIN" ), ST_MakePoint( "MBR_XMAX", "MBR_YMAX" ) ), 27700 ) ) AS place_bbox_area,
	"POPULATED_PLACE" AS place_pop_name,
	"DISTRICT_BOROUGH" AS place_dst_name,
	"COUNTY_UNITARY" AS place_cty_name,
	"REGION" AS place_reg_name,
	"COUNTRY" AS place_cny_name
FROM
	_import_names_csv
WHERE
	"TYPE" = 'populatedPlace';