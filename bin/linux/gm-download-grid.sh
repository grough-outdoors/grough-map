#!/bin/bash

echo "Preparing to download Natural England products..."

echo "-----------------------------------"
echo "--> Downloading archives..."
echo "-----------------------------------"
cd /vagrant/source/grid/

echo "Downloading all grid fishnet data..."
curl -L -o "grid.zip" "https://github.com/charlesroper/OSGB_Grids/archive/master.zip"

echo "--> Download complete. Run gm-import-grid."
