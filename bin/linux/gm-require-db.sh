#!/bin/bash

tempDir=/vagrant/volatile/
binDir=/vagrant/bin/linux/

coreSource=`echo $1 | tr '[:upper:]' '[:lower:]'`
coreProduct=`echo $2 | tr '[:upper:]' '[:lower:]'`
coreSub=`echo $3 | tr '[:upper:]' '[:lower:]'`

tableMask="_src_${coreSource}"
tableVolatileList="${tempDir}/volatile-tables.txt"

if [ ! -z "$coreProduct" ]; then 
	tableMask="${tableMask}_${coreProduct}"
else
	coreProduct="all"
fi

if [ ! -z "$coreSub" ]; then 
	tableMask="${tableMask}_${coreSub}"; 
else
	coreSub="all"
fi

echo "This tool requires data from '${coreSource}' product '${coreProduct}' subset '${coreSub}'... Testing for data..."

# Test for the product's existence in the database
requireSatisfied=0
IFS=$'\n'; for tableName in `echo "\dt" | psql -Ugrough-map grough-map -h 127.0.0.1 -A -t | tr '|' '\n' | grep ${tableMask}`
do
	echo " + Found ${tableName}. Testing for data..."
	rowCount=`psql -Ugrough-map grough-map -h 127.0.0.1 -A -t -c "SELECT Count(*) FROM ${tableName}"`
	if [ ! -z "$rowCount" ] && [ "$rowCount" -gt 0 ]; then
		requireSatisfied=1
		echo "    Data found. Requirement satisfied."
	else
		echo "    No data found."
	fi
done

# Import if required
if [ "$requireSatisfied" -eq 1 ]; then
	echo "I am happy with the data found."
	exit 0
else
	echo " + Attempting to satisfy requirements..."
	if [ -e "$binDir/gm-import-${coreSource}.sh" ]; then
		# Store a list of the current tables
		echo "\dt" | psql -Ugrough-map grough-map -h 127.0.0.1 -A -t | tr '|' '\n' | grep _src_${coreSource}_ > /tmp/current-tables.txt
	
		echo "    Import script found. Attempting to run..."
		"$binDir/gm-import-${coreSource}.sh" "${coreProduct}"
		
		requireSatisfied=0
		IFS=$'\n'; for tableName in `echo "\dt" | psql -Ugrough-map grough-map -h 127.0.0.1 -A -t | tr '|' '\n' | grep ${tableMask}`
		do
			echo " + Found ${tableName}. Testing for data..."
			rowCount=`psql -Ugrough-map grough-map -h 127.0.0.1 -A -t -c "SELECT Count(*) FROM ${tableName}"`
			if [ ! -z "$rowCount" ] && [ "$rowCount" -gt 0 ]; then
				requireSatisfied=1
				echo "    Data found. Requirement satisfied."
			else
				echo "    No data found."
			fi
		done
		
		if [ "$requireSatisfied" -eq 1 ]; then
			echo "I am now happy with the data found."
		else
			echo "    Requirements are still not satisfied. Oh dear. Something is wrong."
			exit 1
		fi
		
	else
		echo "    No import script found. Cannot continue."
		exit 1
	fi
fi

# Add new tables to the volatile list so they can be safely removed			
echo "\dt" | psql -Ugrough-map grough-map -h 127.0.0.1 -A -t | tr '|' '\n' | grep _src_${coreSource}_ > /tmp/new-tables.txt
grep -F -x -v -f /tmp/current-tables.txt /tmp/new-tables.txt >> ${tableVolatileList}
exit 0
