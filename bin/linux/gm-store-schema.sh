#!/bin/bash

echo "Preparing to store key database schema..."

echo "-----------------------------------"
echo "--> Storing tables..."
echo "-----------------------------------"
cd /vagrant/source/schema/

echo "--> Storing edge classes..."
pg_dump -Ugrough-map grough-map -h 127.0.0.1 -t edge_classes > edge_classes.sql

echo "--> Storing edge access types..."
pg_dump -Ugrough-map grough-map -h 127.0.0.1 -t edge_access > edge_access.sql

echo "--> Storing edge schema..."
pg_dump -Ugrough-map grough-map -h 127.0.0.1 -t edge --schema-only > edge.sql

echo "--> Storing edge import highways..."
pg_dump -Ugrough-map grough-map -h 127.0.0.1 -t edge_import_highways > edge_import_highways.sql

echo "--> Storing edge import railways..."
pg_dump -Ugrough-map grough-map -h 127.0.0.1 -t edge_import_railways > edge_import_railways.sql

echo "--> Storing surface classes..."
pg_dump -Ugrough-map grough-map -h 127.0.0.1 -t surface_classes > surface_classes.sql

echo "--> Storing surface schema..."
pg_dump -Ugrough-map grough-map -h 127.0.0.1 -t surface --schema-only > surface.sql

echo "--> Storing elevation schema..."
pg_dump -Ugrough-map grough-map -h 127.0.0.1 -t elevation --schema-only > elevation.sql

echo "--> Storing watercourse schema..."
pg_dump -Ugrough-map grough-map -h 127.0.0.1 -t watercourse --schema-only > watercourse.sql

echo "--> Storing watercourse classes..."
pg_dump -Ugrough-map grough-map -h 127.0.0.1 -t watercourse_classes > watercourse_classes.sql

echo ""
echo "Export complete. Run gm-restore-schema to return."
