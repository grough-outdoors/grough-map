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
	sudo -u postgres psql -c "CREATE EXTENSION postgis; CREATE EXTENSION postgis_topology; CREATE EXTENSION fuzzystrmatch; CREATE EXTENSION unaccent;" $DB_NAME
	
	echo "-----------------------------------"
	echo "--> Changing PostgreSQL settings..."  
	echo "-----------------------------------"
	sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/$PG_VERSION/main/postgresql.conf
	export HBA='echo "host    all     all     192.168.0.0/16 md5" >> /etc/postgresql/'$PG_VERSION'/main/pg_hba.conf'
	echo $HBA | sudo sh
	
	echo "-----------------------------------"
	echo "--> Changing PostgreSQL memory sizes..."  
	echo "-----------------------------------"
	sudo sed -i.bak1 's/max_connections = 100/max_connections = 10/g' /etc/postgresql/9.3/main/postgresql.conf
	sudo sed -i.bak2 's/#work_mem = 1MB/work_mem = 150MB/g' /etc/postgresql/9.3/main/postgresql.conf
	
	echo "-----------------------------------"
	echo "--> Restarting PostgreSQL server..."  
	echo "-----------------------------------"
	sudo /etc/init.d/postgresql restart
}

echo "Beginning to provision the map environment box..."

if [[ ! -e /vagrant/source/env.sh ]]; then
	echo "-----------------------------------"
	echo "--> Generating random password..."
	echo "-----------------------------------"
	NewPassword=`date | sha256sum | base64 | head -c 32`
	sed 's/--PASSWORD--/'${NewPassword}'/g' /vagrant/source/env.sh.default > /vagrant/source/env.sh
fi

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
echo "--> Building OpenCV tools..."  
echo "-----------------------------------"
sudo apt-get -y install libopencv-dev
cd /vagrant/bin/linux/CVTool/
make clean && make cvtool
cd -

echo "-----------------------------------"
echo "--> Installing GRASS GIS..."  
echo "-----------------------------------"
cd /tmp
rm -rf grass*

shellFile=`curl https://grass.osgeo.org/grass70/binary/linux/snapshot/ | grep '\.sh' | grep -o '<a.*href=.*>' | sed 's/<a href="//g' | sed 's/\".*$//'`
tarFile=`curl https://grass.osgeo.org/grass70/binary/linux/snapshot/ | grep '\.tar' | grep -o '<a.*href=.*>' | sed 's/<a href="//g' | sed 's/\".*$//'`

wget "https://grass.osgeo.org/grass70/binary/linux/snapshot/$shellFile"
wget "https://grass.osgeo.org/grass70/binary/linux/snapshot/$tarFile"

sudo rm -rf /usr/local/grass7*
chmod +x "$shellFile"
sudo "./$shellFile" "$tarFile"
cd -

sudo chmod -R 755 /usr/local/bin/grass-*
sudo chmod 755 /usr/local/bin/grass70

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
echo "--> Installing screen..."
echo "-----------------------------------"
sudo apt-get install -y screen

echo "-----------------------------------"
echo "--> Installing Mapnik for Python..."
echo "-----------------------------------"
sudo apt-get install -y python-mapnik 
sudo apt-get install -y mapnik-input-plugin-gdal mapnik-input-plugin-ogr\
  mapnik-input-plugin-postgis \
  mapnik-input-plugin-sqlite \
  mapnik-input-plugin-osm 
  
echo "-----------------------------------"
echo "--> Installing cloud utilities..."
echo "-----------------------------------"
sudo apt-get install -y cloud-utils

if [[ "`ec2metadata --ami-id`" == "ami-"* ]]; then
	regionName=`ec2metadata --availability-zone | sed 's/[a-z]$//i'`
	cd /tmp			
	curl https://amazon-ssm-${regionName}.s3.amazonaws.com/latest/debian_amd64/amazon-ssm-agent.deb -o amazon-ssm-agent.deb
	sudo dpkg -i amazon-ssm-agent.deb
	cd -
fi

echo "-----------------------------------"
echo "--> Converting all line endings..."  
echo "-----------------------------------"
dos2unix /vagrant/bin/linux/*.sh

echo "-----------------------------------"
echo "--> Creating links..."  
echo "-----------------------------------"
sudo rm -f /bin/gm-*
for f in /vagrant/bin/linux/gm-*.sh; do
	if [ `basename $f | grep -o '[-]' | cut -d : -f 1 | uniq -c | sed 's/ -//g'` -le 2 ]; then
		n=`basename $f`
		echo Found tool ${n%.*}
		sudo ln -s $f /bin/${n%.*}
		sudo chmod +x /bin/${n%.*}
	fi
done

echo "--> Installation complete."
