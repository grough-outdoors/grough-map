#!/bin/bash

function createDatabaseServer {
	echo "-----------------------------------"
	echo "--> Installing PostgreSQL server..."
	echo "-----------------------------------"
	sudo apt-get update
	sudo apt-get install -y postgresql-$PG_VERSION postgresql-contrib

	echo "-----------------------------------"
	echo "--> Restarting PostgreSQL server..."  
	echo "-----------------------------------"
	sudo /etc/init.d/postgresql restart
	sleep 5

	echo "-----------------------------------"
	echo "--> Creating cluster.."  
	echo "-----------------------------------"
	sudo -u postgres pg_createcluster $PG_VERSION main --start

	echo "-----------------------------------"
	echo "--> Creating '$DB_USER' database user..."
	echo "-----------------------------------"
	sudo -u postgres psql -c "CREATE ROLE \"$DB_USER\" WITH PASSWORD '$DB_PASS' LOGIN;"

	echo "-----------------------------------"
	echo "--> Creating grough-map database..."
	echo "-----------------------------------"
	sudo -u postgres createdb -O $DB_USER $DB_NAME

	echo "-----------------------------------"
	echo "--> Writing password to file..."
	echo "-----------------------------------"
	echo "*:*:$DB_NAME:$DB_USER:$DB_PASS" > ~/.pgpass
	chmod 0600 ~/.pgpass > /dev/null

	echo "-----------------------------------"
	echo "--> Installing PostGIS extensions..."
	echo "-----------------------------------"
	sudo apt-get install -y postgis postgresql-$PG_VERSION-postgis-2.1

	echo "-----------------------------------"
	echo "--> Applying PostGIS extensions to grough-map database..."
	echo "-----------------------------------"
	sudo -u postgres psql -c "CREATE EXTENSION postgis; CREATE EXTENSION postgis_topology;" $DB_NAME

	echo "-----------------------------------"
	echo "--> Changing PostgreSQL settings..."  
	echo "-----------------------------------"
	sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/$PG_VERSION/main/postgresql.conf
	export HBA='echo "host    all     all     192.168.0.0/16 md5" >> /etc/postgresql/'$PG_VERSION'/main/pg_hba.conf'
	echo $HBA | sudo sh
	
	echo "-----------------------------------"
	echo "--> Restarting PostgreSQL server..."  
	echo "-----------------------------------"
	sudo /etc/init.d/postgresql restart
}

echo "Beginning to provision the map environment box..."

echo "-----------------------------------"
echo "--> Converting line endings..."
echo "-----------------------------------"
sudo apt-get install dos2unix > /dev/null
sudo dos2unix /vagrant/source/env.sh

echo "-----------------------------------"
echo "--> Importing environment variables..."
echo "-----------------------------------"
source /vagrant/source/env.sh

echo "-----------------------------------"
echo "--> Testing for PostgreSQL installation..."
if [ ! -d "/var/lib/postgresql/$PG_VERSION/main" ]; then
	echo "    No data directory found -- provisioning database server"
	createDatabaseServer
else
	echo "    Data directory found -- skipping PostgreSQL provisoning"
fi
echo "-----------------------------------"

echo "-----------------------------------"
echo "--> Testing PostGIS extensions function correctly..."
if [[ $(sudo -u vagrant psql -U $DB_USER -h $DB_HOST -c "SELECT ST_AsText(ST_Transform(ST_SetSRID(ST_MakePoint(400000, 400000), 27700),4326));" -A -t $DB_NAME) = "POINT(-2.00146878339557 53.4967017351455)" ]]; 
then 
	echo "    Correct response received to coordinate transform"
else
	echo "!!! Unexpected response received to coordinate transform"
fi
echo "-----------------------------------"

echo "--> Adding additional database functions..."
sudo -u postgres psql -f /vagrant/source/sql/add_extra_functions.sql $DB_NAME

echo "-----------------------------------"
echo "--> Adding Mapnik v2.3 repository..."
echo "-----------------------------------"
sudo apt-add-repository ppa:mapnik/nightly-2.3 -y 
sudo apt-get update 

echo "-----------------------------------"
echo "--> Installing Mapnik library..."
echo "-----------------------------------"
sudo apt-get install -y libmapnik libmapnik-dev 
sudo apt-get install -y mapnik-utils 

echo "-----------------------------------"
echo "--> Installing Mapnik for Python..."
echo "-----------------------------------"
sudo apt-get install -y python-mapnik 
sudo apt-get install -y mapnik-input-plugin-gdal mapnik-input-plugin-ogr\
  mapnik-input-plugin-postgis \
  mapnik-input-plugin-sqlite \
  mapnik-input-plugin-osm 
  
echo "-----------------------------------"
echo "--> Installing other Python requirements..."
echo "-----------------------------------"
sudo apt-get install -y python-psycopg2

echo "-----------------------------------"
echo "--> Installing LASTools..."
echo "-----------------------------------"
if [ ! -e "/vagrant/bin/linux/LASTools/" ]; then
	echo "--> Removing old version..."
	rm -rf /vagrant/bin/linux/LASTools/
	echo "--> Making new directory..."
	mkdir /vagrant/bin/linux/LASTools/
	echo "--> Downloading latest version..."
	cd /vagrant/bin/linux/LASTools/
	curl -L -o "lastools.zip" "http://www.cs.unc.edu/~isenburg/lastools/download/lastools.zip"
	echo "--> Extracting..."
	unzip lastools.zip
	echo "--> Rearranging..."
	rm -rf lastools.zip
	mv LASTools/* ./
	rm -rf LASTools
	echo "--> Building..."
	make
fi
cd /vagrant

echo "-----------------------------------"
echo "--> Installing NodeJS and CartoCSS..."
echo "-----------------------------------"
sudo apt-get install -y nodejs npm nodejs-legacy
sudo npm install -g carto

echo "-----------------------------------"
echo "--> Installing osm2pgsql..."  
echo "-----------------------------------"
sudo apt-get install -y osm2pgsql

echo "-----------------------------------"
echo "--> Installing ZIP..."  
echo "-----------------------------------"
sudo apt-get install -y zip

echo "-----------------------------------"
echo "--> Installing GDAL binaries..."  
echo "-----------------------------------"
sudo apt-get install -y gdal-bin
sudo apt-get install -y python-gdal

echo "-----------------------------------"
echo "--> Installing ImageMagick..."  
echo "-----------------------------------"
sudo apt-get -y install imagemagick

echo "-----------------------------------"
echo "--> Converting all line endings..."  
echo "-----------------------------------"
dos2unix /vagrant/bin/linux/*.sh

echo "--> Installation complete."
