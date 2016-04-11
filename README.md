# grough-map
High quality mapping for the outdoors. Map tiles are generated using composite data from a number of sources (Ordnance Survey, OpenStreetMap, Environment Agency, Natural England, Natural Resources Wales, etc.). Data and tools are used within Ubuntu LTS through Vagrant.

## Installation steps
1. Install [Oracle VirtualBox](https://www.virtualbox.org/).
2. Install [Vagrant](https://www.vagrantup.com/).
3. Clone from GitHub.
4. Provision the machine
	1. Provision the machine with 'vagrant up'.
	2. Log into the machine with 'vagrant ssh'.
	3. Change directory to '/vagrant/bin/linux/'.
	3. Run each build step.

## Build steps

Load in the basic schema required...
- gm-restore-schema

Download and pull in OSM data
- gm-update-osm 

Fetch the required data from the web...
- gm-download-grid
- gm-download-ne
- gm-download-os (Requires source_email.txt)
- gm-download-osm
- gm-download-ea \<tile\>
- gm-download-nrw \<tile\>
- gm-download-prow	(TODO: Only covers updates from GeoServer)
 
Import source data to the database...
- gm-import-grid
- gm-import-ne
- gm-import-os
- gm-import-prow
  
Build each composite map layer...
- gm-build-transport
- gm-build-buildings
- gm-build-surface
- gm-build-watercourses
- gm-build-features
- gm-build-places
- gm-build-terrain (for each tile, or automatic during gm-tile)
- gm-build-cartography

For each tile to be generated...  
- gm-tile \<tile\>

## Licence

All the code in this repository is licensed under the [GNU General Public License v3](http://www.gnu.org/licenses/gpl-3.0.en.html). You are free to use and distribute it, including for commercial use, but any changes you make must be made available under the GPL with build and install instructions.

OpenStreetMap data is used by these tools, and as such many of the map layers (but not all) are covered by the [Open Database License](http://wiki.openstreetmap.org/wiki/Open_Data_License/Community_Guidelines), which may require you to share improvements you make to the database.
