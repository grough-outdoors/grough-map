#!/bin/bash

partitionID=$1
partitionCount=$2
partitionCommand=$3

if [ -z "$partitionID" ] || [ -z "$partitionCount" ] || [ -z "$partitionCommand" ]; then
	echo "Need partition information."
	exit 1
fi

rm -rf /tmp/partition_full.txt
rm -rf /tmp/partition_list.txt

echo "Partitioning work for ${partitionID} of ${partitionCount}..."
psql -Ugrough-map grough-map -h 127.0.0.1 -A -t -c "SELECT tile_name FROM grid" > /tmp/partition_full.txt
awk "NR % ${partitionCount} == ${partitionID}" /tmp/partition_full.txt > /tmp/partition_list.txt
echo "   Tile count for this system is "`cat /tmp/partition_list.txt | wc -l`

IFS=$'\n'; for tileName in `cat /tmp/partition_list.txt`
do
	"$partitionCommand" "$tileName" "${@:4}"
done
