#!/bin/bash

tempDir=/vagrant/volatile/
binDir=/vagrant/bin/linux/

IFS=$'\n'; for tableName in `cat ${tempDir}/volatile-tables.txt`;
do
	psql -A -t -Ugrough-map grough-map -h 127.0.0.1 -c "DROP TABLE ${tableName};"
done

psql -A -t -Ugrough-map grough-map -h 127.0.0.1 -c "VACUUM;"
