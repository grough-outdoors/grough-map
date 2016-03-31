#!/bin/bash

tablePrefix=_src_os_$1
filterTerm='*.shp'

if [ -n $3 ]
then
	filterTerm=$3
fi

echo "     --> Finding shapefiles..."
IFS=$'\n'; for f in $(find ./ -name $filterTerm)
do 
	echo "         --> Found $f..." 
	baseName=`basename $f`
	baseModes="-S"
	
	if [ "$2" = "normal" ]
	then
		reformedName=`echo $baseName | sed -e 's/\..*$//g' -e 's/[A-Z][A-Z]_//g' -e 's/[A-Z]/_\l&/g' -e 's/[^a-z0-9_]//g' -e 's/\(_\+\)/_/g'`
	elif [ "$2" = "boundaries" ]
	then
		reformedName=`echo _$baseName | sed -e 's/\..*$//g' -e 's/Boundary-line-//g' -e 's/\-/_/g' -e 's/[^A-Za-z0-9_]//g' | tr '[:upper:]' '[:lower:]'`
		baseModes=""
	else
		reformedName=`echo _$baseName | sed -e 's/\..*$//g' -e 's/[^A-Za-z0-9_]//g' | tr '[:upper:]' '[:lower:]'`
	fi
		
	tableName=$tablePrefix$reformedName
	echo "         --> Committing to table $tableName..." 
	if [ ! -e $tableName.sql ]
	then
		echo "DROP TABLE IF EXISTS $tableName;" > $tableName.sql
		shp2pgsql -s 27700 -p $baseModes -W LATIN1 -N skip $f $tableName >> $tableName.sql
	fi
	shp2pgsql -s 27700 -a $baseModes -W LATIN1 -N skip $f $tableName >> $tableName.sql
done
