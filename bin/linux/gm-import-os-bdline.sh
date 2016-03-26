#!/bin/bash

scriptDir=`dirname ${BASH_SOURCE[0]}`

echo "     --> Importing OS BoundaryLine..."
echo "     --> Table prefix will be _src_os_$1"
echo "     --> Script directory is $scriptDir"
$scriptDir/gm-import-os-generic-shapefile.sh $1 boundaries
echo "     --> Processing complete."
