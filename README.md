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

Fetch the required data from the web...
- gm-download-grid
- gm-download-ne
- gm-download-os (Requires source_email.txt)
- gm-download-osm
- gm-download-ea 		(TODO)
- gm-download-prow	(TODO: Only covers updates from GeoServer)
  
Import source data to the database...
- gm-import-grid
- gm-import-ne		(TODO)
- gm-import-os
- gm-import-prow
  
Build each composite map layer...
- gm-build-contours	(TODO)
- gm-build-transport (TO FINISH)
- gm-build-buildings (TO FINISH)
- gm-build-surfaces	(TODO)
- gm-build-natural (TODO)

For each tile to be generated...  
- gm-tile	(TODO)

## Licence

To be confirmed.
