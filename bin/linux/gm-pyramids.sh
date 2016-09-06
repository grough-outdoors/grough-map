#!/bin/bash

echo "Preparing to generate LOD down the chain for a pyramid..."

pyramidID="$1"
pyramidMaxLOD="$2"
binDir=/vagrant/bin/linux/
mapDbServer=localhost

if [[ -z "$pyramidMaxLOD" ]]; then
	pyramidMaxLOD=999
fi

echo "-----------------------------------"
echo "> Generating pyramid chain for ID ${pyramidID} (Max LOD: ${pyramidMaxLOD})..."
echo "-----------------------------------"

IFS=$'\n'; for tileRow in `psql -Ugrough-map grough-map -h ${mapDbServer} -A -t -c "
	SELECT
		p2.grid_id
	FROM
		pyramids p
	LEFT JOIN
		pyramids p2
	ON
		ST_Within(ST_Centroid(p2.grid_square), p.grid_square)
	WHERE
		p.grid_id = ${pyramidID}
	AND
		p2.grid_lod <= ${pyramidMaxLOD}" 2> /dev/null`
do
	IFS='|'; read -r -a tileData <<< "$tileRow"
	pyramidSelected=${tileData[0]}

	echo "Processing pyramid ID ${pyramidSelected}..."
	"${binDir}/gm-pyramids-single.sh" "${pyramidSelected}"
done

echo "Pyramid chain is complete."
