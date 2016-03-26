#!/bin/bash

areaName=$1
tableName=$2

echo "     --> Converting numeric types in $tableName..."
echo "     --> Adding new field for the type..."
psql -A -t -Ugrough-map grough-map -h 127.0.0.1 -c "ALTER TABLE "$tableName" \
	ADD COLUMN class character varying(30);" > /dev/null
echo "     --> Mapping numeric types..."
psql -A -t -Ugrough-map grough-map -h 127.0.0.1 -c "UPDATE "$tableName" SET class=CASE\
	WHEN status=1 THEN 'Footpath'
	WHEN status=2 THEN 'Bridleway'
	WHEN status=3 THEN 'BOAT'
	WHEN status=9 THEN 'Restricted byway' \
	END;" 
> /dev/null
	