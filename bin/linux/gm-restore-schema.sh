#!/bin/bash

echo "Preparing to restore main schema..."

fileBaseDir=/vagrant/source/schema/

echo "-----------------------------------"
echo "--> Restoring..."
echo "-----------------------------------"

echo "--> Restoring edge classes..."
psql -Ugrough-map grough-map -h 127.0.0.1 -c "DROP TABLE IF EXISTS edge_classes CASCADE;"
psql -Ugrough-map grough-map -h 127.0.0.1 -f "${fileBaseDir}edge_classes.sql" > /dev/null 

echo "--> Restoring edge access types..."
psql -Ugrough-map grough-map -h 127.0.0.1 -c "DROP TABLE IF EXISTS edge_access CASCADE;"
psql -Ugrough-map grough-map -h 127.0.0.1 -f "${fileBaseDir}edge_access.sql" > /dev/null 

echo "--> Restoring edge schema..."
psql -Ugrough-map grough-map -h 127.0.0.1 -f "${fileBaseDir}edge.sql" > /dev/null 

echo "--> Restoring edge route relation schema..."
psql -Ugrough-map grough-map -h 127.0.0.1 -f "${fileBaseDir}edge_route.sql" > /dev/null 

echo "--> Restoring route schema..."
psql -Ugrough-map grough-map -h 127.0.0.1 -f "${fileBaseDir}route.sql" > /dev/null 

echo "--> Restoring edge import highways..."
psql -Ugrough-map grough-map -h 127.0.0.1 -c "DROP TABLE IF EXISTS edge_import_highways CASCADE;"
psql -Ugrough-map grough-map -h 127.0.0.1 -f "${fileBaseDir}edge_import_highways.sql" > /dev/null 

echo "--> Restoring edge import railways..."
psql -Ugrough-map grough-map -h 127.0.0.1 -c "DROP TABLE IF EXISTS edge_import_railways CASCADE;"
psql -Ugrough-map grough-map -h 127.0.0.1 -f "${fileBaseDir}edge_import_railways.sql" > /dev/null 

echo "--> Restoring edge import routes..."
psql -Ugrough-map grough-map -h 127.0.0.1 -c "DROP TABLE IF EXISTS edge_import_routes CASCADE;"
psql -Ugrough-map grough-map -h 127.0.0.1 -f "${fileBaseDir}edge_import_routes.sql" > /dev/null 

echo "--> Restoring surface classes..."
psql -Ugrough-map grough-map -h 127.0.0.1 -c "DROP TABLE IF EXISTS surface_classes CASCADE;"
psql -Ugrough-map grough-map -h 127.0.0.1 -f "${fileBaseDir}surface_classes.sql" > /dev/null 

echo "--> Restoring surface schema..."
psql -Ugrough-map grough-map -h 127.0.0.1 -f "${fileBaseDir}surface.sql" > /dev/null 

echo "--> Restoring elevation schema..."
psql -Ugrough-map grough-map -h 127.0.0.1 -f "${fileBaseDir}elevation.sql" > /dev/null 

echo "--> Restoring elevation source schema..."
psql -Ugrough-map grough-map -h 127.0.0.1 -f "${fileBaseDir}elevation_source.sql" > /dev/null 

echo "--> Restoring watercourse schema..."
psql -Ugrough-map grough-map -h 127.0.0.1 -f "${fileBaseDir}watercourse.sql" > /dev/null 

echo "--> Restoring watercourse classes..."
psql -Ugrough-map grough-map -h 127.0.0.1 -c "DROP TABLE IF EXISTS watercourse_classes CASCADE;"
psql -Ugrough-map grough-map -h 127.0.0.1 -f "${fileBaseDir}watercourse_classes.sql" > /dev/null 

echo "--> Restoring place schema..."
psql -Ugrough-map grough-map -h 127.0.0.1 -f "${fileBaseDir}place.sql" > /dev/null 

echo "--> Restoring place classes..."
psql -Ugrough-map grough-map -h 127.0.0.1 -c "DROP TABLE IF EXISTS place_classes CASCADE;"
psql -Ugrough-map grough-map -h 127.0.0.1 -f "${fileBaseDir}place_classes.sql" > /dev/null 

echo "--> Restoring point feature schema..."
psql -Ugrough-map grough-map -h 127.0.0.1 -f "${fileBaseDir}feature_point.sql" > /dev/null 

echo "--> Restoring linear feature schema..."
psql -Ugrough-map grough-map -h 127.0.0.1 -f "${fileBaseDir}feature_linear.sql" > /dev/null 

echo "--> Restoring feature classes..."
psql -Ugrough-map grough-map -h 127.0.0.1 -c "DROP TABLE IF EXISTS feature_classes CASCADE;"
psql -Ugrough-map grough-map -h 127.0.0.1 -f "${fileBaseDir}feature_classes.sql" > /dev/null 

echo "--> Restoring zone schema..."
psql -Ugrough-map grough-map -h 127.0.0.1 -f "${fileBaseDir}zone.sql" > /dev/null 

echo "--> Restoring zone classes..."
psql -Ugrough-map grough-map -h 127.0.0.1 -c "DROP TABLE IF EXISTS zone_classes CASCADE;"
psql -Ugrough-map grough-map -h 127.0.0.1 -f "${fileBaseDir}zone_classes.sql" > /dev/null 

echo "--> Restoring source schema..."
psql -Ugrough-map grough-map -h 127.0.0.1 -f "${fileBaseDir}source.sql" > /dev/null 

echo "--> Restoring licences..."
psql -Ugrough-map grough-map -h 127.0.0.1 -c "DROP TABLE IF EXISTS licence CASCADE;"
psql -Ugrough-map grough-map -h 127.0.0.1 -f "${fileBaseDir}licence.sql" > /dev/null 

echo "--> Restoring route classes..."
psql -Ugrough-map grough-map -h 127.0.0.1 -c "DROP TABLE IF EXISTS route_classes CASCADE;"
psql -Ugrough-map grough-map -h 127.0.0.1 -f "${fileBaseDir}route_classes.sql" > /dev/null 

echo "--> Restoring feature import classes..."
psql -Ugrough-map grough-map -h 127.0.0.1 -c "DROP TABLE IF EXISTS feature_import CASCADE;"
psql -Ugrough-map grough-map -h 127.0.0.1 -f "${fileBaseDir}feature_import.sql" > /dev/null 

echo "--> Restoring place import classes..."
psql -Ugrough-map grough-map -h 127.0.0.1 -c "DROP TABLE IF EXISTS place_import CASCADE;"
psql -Ugrough-map grough-map -h 127.0.0.1 -f "${fileBaseDir}place_import.sql" > /dev/null 

echo "--> Restoring view for edge extended..."
psql -Ugrough-map grough-map -h 127.0.0.1 -f "${fileBaseDir}edge_extended.sql" > /dev/null 

echo "--> Restoring view for edge labels..."
psql -Ugrough-map grough-map -h 127.0.0.1 -f "${fileBaseDir}edge_label.sql" > /dev/null 

echo "--> Restoring view for feature linear extended..."
psql -Ugrough-map grough-map -h 127.0.0.1 -f "${fileBaseDir}feature_linear_extended.sql" > /dev/null 

echo "--> Restoring view for feature point extended..."
psql -Ugrough-map grough-map -h 127.0.0.1 -f "${fileBaseDir}feature_point_extended.sql" > /dev/null

echo "--> Restoring view for place extended..."
psql -Ugrough-map grough-map -h 127.0.0.1 -f "${fileBaseDir}place_extended.sql" > /dev/null 

echo "--> Restoring view for surface extended..."
psql -Ugrough-map grough-map -h 127.0.0.1 -f "${fileBaseDir}surface_extended.sql" > /dev/null 

echo "--> Restoring view for watercourse extended..."
psql -Ugrough-map grough-map -h 127.0.0.1 -f "${fileBaseDir}watercourse_extended.sql" > /dev/null 

echo "--> Restoring view for zone extended..."
psql -Ugrough-map grough-map -h 127.0.0.1 -f "${fileBaseDir}zone_extended.sql" > /dev/null 

echo "--> Restoring view for watercourse labels..."
psql -Ugrough-map grough-map -h 127.0.0.1 -f "${fileBaseDir}watercourse_label.sql" > /dev/null 

echo "--> Restoring view for edge statistics..."
psql -Ugrough-map grough-map -h 127.0.0.1 -f "${fileBaseDir}edge_statistics.sql" > /dev/null 

echo "--> Restoring view for feature labels..."
psql -Ugrough-map grough-map -h 127.0.0.1 -f "${fileBaseDir}feature_label.sql" > /dev/null 

echo "--> Restoring view for raw obstructions..."
psql -Ugrough-map grough-map -h 127.0.0.1 -f "${fileBaseDir}raw_obstructions.sql" > /dev/null 

echo "--> Restoring view for route extended..."
psql -Ugrough-map grough-map -h 127.0.0.1 -f "${fileBaseDir}route_extended.sql" > /dev/null 

echo "--> Restoring view for source extended..."
psql -Ugrough-map grough-map -h 127.0.0.1 -f "${fileBaseDir}source_extended.sql" > /dev/null 


echo "--> Restore complete."
