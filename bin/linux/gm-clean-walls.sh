#!/bin/bash

echo "Preparing to clean walls vectors..."

echo "-----------------------------------"
echo "--> Converting to SQL files..."
echo "-----------------------------------"
cd /vagrant/volatile/walls/
shp2pgsql -d -s 27700 -S Walls_Thres40.shp _src_walls_t40 > walls_t40.sql
shp2pgsql -d -s 27700 -S Walls_Thres90.shp _src_walls_t90 > walls_t90.sql
shp2pgsql -d -s 27700 -S Walls_Thres200.shp _src_walls_t200 > walls_t200.sql

echo "-----------------------------------"
echo "--> Importing SQL files..."
echo "-----------------------------------"
psql -Ugrough-map grough-map -h 127.0.0.1 -f walls_t40.sql
psql -Ugrough-map grough-map -h 127.0.0.1 -f walls_t90.sql
psql -Ugrough-map grough-map -h 127.0.0.1 -f walls_t200.sql

echo "--> Processing complete."
