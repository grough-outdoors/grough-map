#!/bin/bash

echo "Starting to update OpenStreetMap..."

cd /vagrant/source/ > /dev/null
mkdir osm > /dev/null

if test `find * -mmin +1440`
then
	echo "--> Downloading latest version..."
	wget http://download.geofabrik.de/europe/great-britain-latest.osm.pbf
else
	echo "--> Skipping download -- copy is <1 day old"
fi

echo "--> Importing to database..."
osm2pgsql --create -d grough-map -s --username=grough-map -H localhost --unlogged -E 27700 -p _src_osm great-britain-latest.osm.pbf

echo "--> Dropping temporary tables..."
echo "    _src_osm_ways..."
psql -Ugrough-map grough-map -h 127.0.0.1 -c "DROP TABLE IF EXISTS _src_osm_ways;"
echo "    _src_osm_nodes..."
psql -Ugrough-map grough-map -h 127.0.0.1 -c "DROP TABLE IF EXISTS _src_osm_nodes;"
echo "    _src_osm_rels..."
psql -Ugrough-map grough-map -h 127.0.0.1 -c "DROP TABLE IF EXISTS _src_osm_rels;"

echo "--> Performing full vacuum..."
psql -Ugrough-map grough-map -h 127.0.0.1 -c "VACUUM FULL;"

echo "--> Update complete."
