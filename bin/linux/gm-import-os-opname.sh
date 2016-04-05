#!/bin/bash

scriptDir=`dirname ${BASH_SOURCE[0]}`
tableName=_src_os_$1

echo "     --> Importing OS OpenNames..."

echo "     --> Creating import table..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	DROP TABLE IF EXISTS $tableName;
	CREATE TABLE $tableName
	(
		id						character varying(39),
		names_uri				character varying(80),
		name1					character varying(80),
		name1_lang				character varying(3),
		name2					character varying(80),
		name2_lang				character varying(3),
		type					character varying(30),
		local_type				character varying(30),
		geometry_x				double precision,
		geometry_y				double precision,
		most_detail_view_res	integer,
		least_detail_view_res	integer,
		mbr_xmin				double precision,
		mbr_ymin				double precision,
		mbr_xmax				double precision,
		mbr_ymax				double precision,
		postcode_district		character varying(4),
		postcode_district_uri	character varying(60),
		populated_place			character varying(103),
		populated_place_uri		character varying(60),
		populated_place_type	character varying(80),
		district_borough		character varying(80),
		district_borough_uri	character varying(80),
		district_borough_type	character varying(80),
		county_unitary			character varying(80),
		county_unitary_uri		character varying(80),
		county_unitary_type		character varying(80),
		region					character varying(30),
		region_uri				character varying(60),
		country					character varying(30),
		country_uri				character varying(60),
		related_spatial_object	character varying(20),
		same_as_dbpedia			character varying(100),
		same_as_geonames		character varying(100)		
	);
EoSQL

echo "     --> Finding CSV files..."
IFS=$'\n'; for f in $(find ./ -name '*.csv')
do 
	baseName=`basename $f`
	fullPath=`readlink -f $f`
	echo "         --> Importing $baseName from $f..." 
	sudo -u postgres psql grough-map -c "COPY $tableName FROM '${fullPath}' DELIMITER ',' CSV;"
done

echo "     --> Adding geometries to table..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	DELETE FROM _src_os_opname WHERE type = 'transportNetwork';
	DELETE FROM _src_os_opname WHERE local_type = 'Postcode';
	ALTER TABLE _src_os_opname ADD COLUMN db_id bigserial;
	ALTER TABLE _src_os_opname ADD CONSTRAINT "PKEY: _src_os_opname::db_id" PRIMARY KEY (db_id);
	ALTER TABLE _src_os_opname ADD COLUMN geom_point geometry(Point, 27700);
	ALTER TABLE _src_os_opname ADD COLUMN geom_bbox geometry(Polygon, 27700);
	UPDATE _src_os_opname SET geom_point = ST_SetSRID(ST_Point(geometry_x, geometry_y), 27700);
	UPDATE _src_os_opname SET geom_bbox = ST_SetSRID(ST_MakeBox2D(ST_Point(mbr_xmin, mbr_ymin), ST_Point(mbr_xmax, mbr_ymax)), 27700);
EoSQL

echo "     --> Cleaning and vacuuming..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	VACUUM FULL _src_os_opname;
EoSQL

echo "     --> Processing complete."
