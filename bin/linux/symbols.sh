#!/bin/bash

echo "Generating symbols for tile..."

binDir=/vagrant/bin/linux
tileName=`echo $1 | tr '[:lower:]' '[:upper:]'`
echo " Tile name : ${tileName}"

echo " --> Removing old symbols..."
rm -rf /vagrant/volatile/symbols

echo " --> Generating generic symbols..."
"${binDir}/symbol-generator.sh" "NCN"
"${binDir}/symbol-generator.sh" "RCN"
"${binDir}/symbol-generator.sh" "NT"

echo " --> Starting volatile carto file..."
echo ".route-label {
    [class_name='National cycle network'] {
		marker-file: url('/vagrant/volatile/symbols/symbol-NCN.png');
	}
	[class_name='Regional cycle network'] {
		marker-file: url('/vagrant/volatile/symbols/symbol-RCN.png');
	}
	[class_name='National trail'] {
		marker-file: url('/vagrant/volatile/symbols/symbol-NT.png');
	}
" > "$binDir/Mapnik/grough_map_volatile.mss"

echo " --> Identifying routes..."
IFS=$'\n'; for routeInfo in `psql -Ugrough-map grough-map -h 127.0.0.1 -A -t -c "
	SELECT DISTINCT
		route_class,
		route_ref,
		class_name
	FROM
	(
		SELECT
			route_ref,
			CASE WHEN class_name = 'National cycle network' THEN 'NCN'
				 WHEN class_name = 'Regional cycle network' THEN 'RCN'
			END AS route_class,
			class_name
		FROM
			grid g
		INNER JOIN
			route_extended r
		ON
			g.tile_geom && r.edge_geom
		WHERE
			g.tile_name = '${tileName}'
	) SA
	WHERE
		route_ref IS NOT NULL
	AND
		route_class IS NOT NULL
"`
do
	IFS='|'; read -r -a routeData <<< "${routeInfo}"
	routeClass="${routeData[0]}"
	routeNumber="${routeData[1]}"
	routeFullClass="${routeData[2]}"
	echo "      Require symbol for ${routeClass} (${routeFullClass}) route ${routeNumber}"
	
	"${binDir}/symbol-generator.sh" "${routeClass}" "${routeNumber}"
	
	echo "    [class_name='${routeFullClass}'][route_ref='${routeNumber}'] {
		marker-file: url('/vagrant/volatile/symbols/symbol-${routeClass}-${routeNumber}.png');
	} " >> "$binDir/Mapnik/grough_map_volatile.mss"
done

echo " --> Closing volatile carto file..."
echo "
}" >> "$binDir/Mapnik/grough_map_volatile.mss"