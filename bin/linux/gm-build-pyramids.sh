#!/bin/bash

binDir=/vagrant/pipeline/bin/
mapDbServer=localhost
targetTable=pyramids
lodLevels=6

echo "-----------------------------------"
echo "--> Generating 3D grid..."
echo "-----------------------------------"

psql -Ugrough-map grough-map -h ${mapDbServer} -A -t -c "
	DROP TABLE IF EXISTS ${targetTable};

	CREATE TABLE
		${targetTable}
	AS SELECT
		ST_SetSRID(ST_MakeBox2D(ST_Point(grid_lod0_x_min, grid_lod0_y_min), ST_Point(grid_lod0_x_min + grid_lod0_size, grid_lod0_y_min + grid_lod0_size)), 27700) AS grid_square,
		0::integer AS grid_lod
	FROM
	(
		SELECT
			generate_series(0, (grid_lod0_x_count * grid_lod0_size)::integer, grid_lod0_size) AS grid_lod0_x_min,
			generate_series(0, (grid_lod0_y_count * grid_lod0_size)::integer, grid_lod0_size) AS grid_lod0_y_min,
			grid_lod0_size
		FROM
		(
			SELECT
				ceil((grid_x_max - grid_x_min) / grid_lod0_size) AS grid_lod0_x_count,
				ceil((grid_y_max - grid_y_min) / grid_lod0_size) AS grid_lod0_y_count,
				grid_lod0_size
			FROM
			(
				SELECT
					ST_XMin(ST_Collect(tile_geom))::integer AS grid_x_min,
					ST_XMax(ST_Collect(tile_geom))::integer AS grid_x_max,
					ST_YMin(ST_Collect(tile_geom))::integer AS grid_y_min,
					ST_YMax(ST_Collect(tile_geom))::integer AS grid_y_max,
					160000 AS grid_lod0_size
				FROM
					grid
			) SA
		) SB
	) SC
	ORDER BY
		grid_lod0_x_min ASC, 
		grid_lod0_y_min ASC;

	SELECT populate_geometry_columns('${targetTable}'::regclass); 
	ALTER TABLE ${targetTable} ADD COLUMN grid_id serial;
"

for i in `seq 0 ${lodLevels}`; do
echo "    Processing LOD${i}..."
psql -Ugrough-map grough-map -h ${mapDbServer} -A -t -c "
	INSERT INTO
		${targetTable}
		(grid_square, grid_lod)
	SELECT 
		*
	FROM
	(
		SELECT 
			grid_square,
			grid_lod
		FROM
		(
			SELECT DISTINCT ON (grid_square, grid_lod)
				(ST_Dump(
					ST_Split(
						ST_Split(
							grid_square,
							ST_SetSRID(ST_MakeLine(
								ST_Point((ST_XMin(grid_square) + (ST_XMax(grid_square) - ST_XMin(grid_square)) / 2), ST_YMin(grid_square)),
								ST_Point((ST_XMin(grid_square) + (ST_XMax(grid_square) - ST_XMin(grid_square)) / 2), ST_YMax(grid_square))
							),27700)
						),
						ST_SetSRID(ST_MakeLine(
							ST_Point(ST_XMin(grid_square), (ST_YMin(grid_square) + (ST_YMax(grid_square) - ST_YMin(grid_square)) / 2)),
							ST_Point(ST_XMax(grid_square), (ST_YMin(grid_square) + (ST_YMax(grid_square) - ST_YMin(grid_square)) / 2))
						), 27700)
					)
				 )).geom AS grid_square,
				grid_lod + 1 AS grid_lod
			FROM
				${targetTable} t
			WHERE
				grid_lod = ${i}
		) SA
	) SB
	ORDER BY
		ST_XMin(grid_square) ASC,
		ST_YMin(grid_square) ASC;
"
done

echo "    Removing non-required entities..."
psql -Ugrough-map grough-map -h ${mapDbServer} -A -t -c "
	DELETE FROM
		${targetTable}
	WHERE
		grid_id IN 
	(
		SELECT DISTINCT ON (grid_id)
			grid_id
		FROM
			${targetTable} t
		LEFT JOIN
			grid g
		ON
			g.tile_geom && t.grid_square
		WHERE
			tile_geom IS NULL
	);
"
