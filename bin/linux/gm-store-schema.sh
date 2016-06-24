#!/bin/bash

echo "Preparing to store key database schema..."

echo "-----------------------------------"
echo "--> Storing tables..."
echo "-----------------------------------"
cd /vagrant/source/schema/

echo "--> Storing edge classes..."
pg_dump -Ugrough-map grough-map -h 127.0.0.1 -t edge_classes -c > edge_classes.sql

echo "--> Storing edge access types..."
pg_dump -Ugrough-map grough-map -h 127.0.0.1 -t edge_access -c > edge_access.sql

echo "--> Storing edge schema..."
pg_dump -Ugrough-map grough-map -h 127.0.0.1 -t edge --schema-only > edge.sql

echo "--> Storing edge import highways..."
pg_dump -Ugrough-map grough-map -h 127.0.0.1 -t edge_import_highways -c > edge_import_highways.sql

echo "--> Storing edge import railways..."
pg_dump -Ugrough-map grough-map -h 127.0.0.1 -t edge_import_railways -c > edge_import_railways.sql

echo "--> Storing surface classes..."
pg_dump -Ugrough-map grough-map -h 127.0.0.1 -t surface_classes -c > surface_classes.sql

echo "--> Storing surface schema..."
pg_dump -Ugrough-map grough-map -h 127.0.0.1 -t surface --schema-only > surface.sql

echo "--> Storing elevation schema..."
pg_dump -Ugrough-map grough-map -h 127.0.0.1 -t elevation --schema-only > elevation.sql

echo "--> Storing elevation source schema..."
pg_dump -Ugrough-map grough-map -h 127.0.0.1 -t elevation_source --schema-only > elevation_source.sql

echo "--> Storing raw obstructions schema..."
pg_dump -Ugrough-map grough-map -h 127.0.0.1 -t raw_obstructions --schema-only > raw_obstructions.sql

echo "--> Storing watercourse schema..."
pg_dump -Ugrough-map grough-map -h 127.0.0.1 -t watercourse --schema-only > watercourse.sql

echo "--> Storing source schema..."
pg_dump -Ugrough-map grough-map -h 127.0.0.1 -t source --schema-only > source.sql

echo "--> Storing watercourse classes..."
pg_dump -Ugrough-map grough-map -h 127.0.0.1 -t watercourse_classes -c > watercourse_classes.sql

echo "--> Storing place schema..."
pg_dump -Ugrough-map grough-map -h 127.0.0.1 -t place --schema-only > place.sql

echo "--> Storing place classes..."
pg_dump -Ugrough-map grough-map -h 127.0.0.1 -t place_classes -c > place_classes.sql

echo "--> Storing point feature schema..."
pg_dump -Ugrough-map grough-map -h 127.0.0.1 -t feature_point --schema-only > feature_point.sql

echo "--> Storing linear feature schema..."
pg_dump -Ugrough-map grough-map -h 127.0.0.1 -t feature_linear --schema-only > feature_linear.sql

echo "--> Storing feature classes..."
pg_dump -Ugrough-map grough-map -h 127.0.0.1 -t feature_classes -c > feature_classes.sql

echo "--> Storing zone schema..."
pg_dump -Ugrough-map grough-map -h 127.0.0.1 -t zone --schema-only > zone.sql

echo "--> Storing zone classes..."
pg_dump -Ugrough-map grough-map -h 127.0.0.1 -t zone_classes -c > zone_classes.sql

echo "--> Storing feature import classes..."
pg_dump -Ugrough-map grough-map -h 127.0.0.1 -t feature_import > feature_import.sql

echo "--> Storing place import classes..."
pg_dump -Ugrough-map grough-map -h 127.0.0.1 -t place_import > place_import.sql

echo "--> Storing licences..."
pg_dump -Ugrough-map grough-map -h 127.0.0.1 -t licence > licence.sql

echo ""
echo "Export complete. Run gm-restore-schema to return."
