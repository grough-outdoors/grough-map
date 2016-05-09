#!/bin/bash

tempDir=/vagrant/volatile/
sourceDir=/vagrant/source/
binDir=/vagrant/bin/linux/

# Remove persistent tables
grep -F -x -v -f ${sourceDir}/persistent-tables.txt ${tempDir}/volatile-tables.txt  > ${tempDir}/volatile-tables.txt

IFS=$'\n'; for tableName in `cat ${tempDir}/volatile-tables.txt`;
do
	psql -A -t -Ugrough-map grough-map -h 127.0.0.1 -c "DROP TABLE ${tableName};"
done

psql -A -t -Ugrough-map grough-map -h 127.0.0.1 -c "VACUUM;"
echo "" > ${tempDir}/volatile-tables.txt
