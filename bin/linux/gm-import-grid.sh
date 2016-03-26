#!/bin/bash

echo "Preparing to import Natural England products..."

fileBaseDir=/vagrant/source/grid/
binDir=../../bin/linux

echo "-----------------------------------"
echo "--> Extracting archives..."
echo "-----------------------------------"
cd $fileBaseDir
for z in *.zip
do
	echo " --> Extracting archive..."
	unzip -j -o "$z"
done

echo "-----------------------------------"
echo "--> Importing base to database..."
echo "-----------------------------------"
echo " --> Converting to SQL file..."
shp2pgsql -s 27700 -d -W LATIN1 -N skip OSGB_Grid_10km.shp _src_grid > _src_grid.sql 2> /dev/null
echo " --> Removing unneeded files..."
for f in `ls -I*.zip -I*.sql`
do
	echo "   --> Deleting file $f..."
	rm -rf "$f"
done
echo " --> Loading to database..."
psql -Ugrough-map grough-map -h 127.0.0.1 -f _src_grid.sql > /dev/null

echo "-----------------------------------"
echo "--> Converting to standard table format..."
echo "-----------------------------------"
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	DROP TABLE IF EXISTS grid;

	CREATE TABLE
		grid
	(
		tile_id	serial,
		tile_name character(4),
		tile_geom geometry(Polygon,27700),
		CONSTRAINT "PKEY: tile::tile_id" PRIMARY KEY (tile_id)
	);

	ALTER TABLE grid OWNER TO "grough-map";
		
	INSERT INTO
		grid (tile_name, tile_geom)
	SELECT
		tile_name AS tile_name,
		(ST_Dump(geom)).geom AS tile_geom
	FROM
		_src_grid;

	CREATE INDEX "Idx: grid::tile_geom"
		ON grid
		USING gist
		(tile_geom);
	CREATE INDEX "Idx: grid::grid_tile"
		ON grid 
		USING btree 
		(tile_name);

	DROP TABLE
		_src_grid;
EoSQL

echo "--> Import complete."
