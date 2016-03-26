#!/bin/bash

areaName=$1
tableName=$2

echo "     --> Converting numeric types in $tableName..."
echo "     --> Adding new field for the type..."
psql -A -t -Ugrough-map grough-map -h 127.0.0.1 -c "ALTER TABLE "$tableName" \
	ADD COLUMN class character varying(30);" > /dev/null
echo "     --> Mapping numeric types..."
psql -A -t -Ugrough-map grough-map -h 127.0.0.1 -c "UPDATE "$tableName" SET class=CASE\
	WHEN street_sub LIKE 'FTP%' THEN 'Footpath'
	WHEN street_sub LIKE 'BDL%' THEN 'Bridleway'
	WHEN street_sub='BWYRES' THEN 'Restricted byway'
	WHEN street_sub='BWY' THEN 'BOAT'
	END;" 
> /dev/null
	