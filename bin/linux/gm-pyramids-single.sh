#!/bin/bash

echo "Preparing to generate LOD levels around a tile..."

pyramidID=`echo $1 | tr '[:lower:]' '[:upper:]'`
binDir=/vagrant/bin/linux/
targetDir=/vagrant/product/
mapSourceDir=/vagrant/product/
mapDbServer=localhost
outputQuality="90%"
outputSea="#C0E0EF"

echo "-----------------------------------"
echo "--> Generating pyramid for ID ${pyramidID}..."
echo "-----------------------------------"

round()
{
	echo $(printf %.$2f $(echo "scale=$2;(((10^$2)*$1)+0.5)/(10^$2)" | bc))
};

tileList=()
tileCount=0
mkdir /tmp/texture 2> /dev/null

echo "Resizing source tiles..."
IFS=$'\n'; for tileRow in `psql -Ugrough-map grough-map -h ${mapDbServer} -A -t -c "
	SELECT
		CASE WHEN tile_name IS NULL THEN 'off_grid_' || ST_XMin(grid_square)::integer || ST_YMin(grid_square)::integer
		     ELSE tile_name
		END AS tile_name,
		grid_lod,
		(ST_XMax(grid_square) - ST_XMin(grid_square))::integer AS grid_size,
		ST_XMin(grid_square)::integer % 10000 AS grid_offset_x,
		ST_YMin(grid_square)::integer % 10000 AS grid_offset_y
	FROM
	(
		SELECT
			*,
			ST_SetSRID(ST_MakeBox2D(ST_Point(grid_x_min, grid_y_min), ST_Point(grid_x_min + 10000, grid_y_min + 10000)), 27700) AS grid_square_tile
		FROM
		(
			SELECT
				*,
				generate_series(ST_XMin(grid_square)::integer, (ST_XMax(grid_square) - least(ST_XMax(grid_square) - ST_XMin(grid_square), 10000)::integer)::integer, least(ST_XMax(grid_square) - ST_XMin(grid_square), 10000)::integer) AS grid_x_min
			FROM
				pyramids
			LEFT JOIN
				generate_series(ST_YMin(grid_square)::integer, (ST_YMax(grid_square) - least(ST_YMax(grid_square) - ST_YMin(grid_square), 10000)::integer)::integer, least(ST_YMax(grid_square) - ST_YMin(grid_square), 10000)::integer) AS grid_y_min
			ON
				true
			WHERE
				grid_id = ${pyramidID}
		) SA
	) n
	LEFT JOIN
		grid g
	ON
		n.grid_square && g.tile_geom
	AND
		( ST_Equals(ST_SnapToGrid(g.tile_geom, 10000), ST_SnapToGrid(n.grid_square_tile, 10000)) OR ST_XMax(grid_square) - ST_XMin(grid_square) < 10000 )
	AND
		( ST_Intersects(n.grid_square, ST_Centroid(g.tile_geom)) OR ST_Within(ST_SnapToGrid(n.grid_square, 1000.0), ST_SnapToGrid(g.tile_geom, 1000.0)) )
	ORDER BY
		ST_YMax(grid_square_tile) DESC,
		ST_XMin(grid_square_tile) ASC;
" 2> /dev/null`
do
	IFS='|'; read -r -a tileData <<< "$tileRow"
	tileName=${tileData[0]}
	tileLOD=${tileData[1]}
	tileSize=${tileData[2]}
	tileOffsetX=${tileData[3]}
	tileOffsetY=${tileData[4]}
	textureSize=$(echo "(1024/(${tileSize}/10000))*2" | bc -l)
	
	if [ -e "${mapSourceDir}${tileName}.png" ]; then
		echo "   Resizing ${tileName}..."
		if [[ "$tileSize" -lt 10000 ]]; then
			echo "   No size reduction required because of resolution..."
			tileList+="${mapSourceDir}${tileName}.png " # convert "${mapSourceDir}${tileName}.png" "/tmp/texture/${tileName}.png"
		else
			convert "${mapSourceDir}${tileName}.png" -resize ${textureSize}x${textureSize} "/tmp/texture/${tileName}.png"
			tileList+="/tmp/texture/${tileName}.png "
		fi
	else
		# Attempt to create the tile
		gm-tile ${tileName}
		if [ -e "${mapSourceDir}${tileName}.png" ]; then
			if [[ "$tileSize" -lt 10000 ]]; then
				echo "   No size reduction required because of resolution..."
				tileList += "${mapSourceDir}${tileName}.png " # convert "${mapSourceDir}${tileName}.png" "/tmp/texture/${tileName}.png"
			else
				convert "${mapSourceDir}${tileName}.png" -resize ${textureSize}x${textureSize} "/tmp/texture/${tileName}.png"
				tileList+="/tmp/texture/${tileName}.png "
			fi
		else
			convert -size ${textureSize}x${textureSize} xc:"${outputSea}" /tmp/texture/${tileName}.png
			tileList+="/tmp/texture/${tileName}.png "
		fi
	fi
	tileCount=$((tileCount+1))
done

tileCols=$(echo "${tileSize}/10000" | bc -l)
tileCols=$(round ${tileCols} 0)
if [[ "${tileCols}" -le 0 ]]; then
	tileCols=1
fi
tileDims=$(echo "1024/${tileCols}" | bc -l)

echo "Have ${tileCount} tiles to merge in ${tileCols} x ${tileCols}."
echo "Tile is LOD${tileLOD} and texture size per image is ${tileDims}"
echo "Grid square covers ${tileSize}m, and has relative offset ${tileOffsetX}, ${tileOffsetY}"
echo "   Sources: ${tileList[@]}"

if [[ $tileSize -ge 10000 ]]; then
	command="montage "${tileList[@]}" -tile ${tileCols}x${tileCols} -geometry ${tileDims}x${tileDims}+0+0 -background '#c0e0ef' -quality "${outputQuality}" ${targetDir}/pyramid/LOD${tileLOD}/${pyramidID}.jpg"
else 
	echo "Need to divide tile."
	
	tileSubCount=$(echo "(10000/${tileSize})" | bc -l)
	tileSubCount=$(round ${tileSubCount} 0)
	tileSubOffsetX=$(echo "${tileOffsetX}/(10000/${tileSubCount})" | bc -l)
	tileSubOffsetX=$(round ${tileSubOffsetX} 0)
	tileSubOffsetY=$(echo "${tileSubCount} - ${tileOffsetY}/(10000/${tileSubCount}) - 1" | bc -l)
	tileSubOffsetY=$(round ${tileSubOffsetY} 0)
	tilePixelSize=$(echo "(8192/${tileSubCount})" | bc -l)
	tilePixelSize=$(round ${tilePixelSize} 0)
	tilePixelOffsetX=$(echo "(8192/${tileSubCount})*${tileSubOffsetX}" | bc -l)
	tilePixelOffsetX=$(round ${tilePixelOffsetX} 0)
	tilePixelOffsetY=$(echo "(8192/${tileSubCount})*${tileSubOffsetY}" | bc -l)
	tilePixelOffsetY=$(round ${tilePixelOffsetY} 0)
	
	echo "Internal offset is (${tileSubOffsetX}, ${tileSubOffsetY}) of ${tileSubCount}"
	echo "Pixel base is (${tilePixelOffsetX}, ${tilePixelOffsetY}) and pixel size is ${tilePixelSize}"

	command="convert "${tileList[@]}" -crop ${tilePixelSize}x${tilePixelSize}+${tilePixelOffsetX}+${tilePixelOffsetY} +repage -resize ${tileDims}x${tileDims} -quality "${outputQuality}" ${targetDir}/pyramid/LOD${tileLOD}/${pyramidID}.jpg"
fi

mkdir "${targetDir}/pyramid" 2> /dev/null
mkdir "${targetDir}/pyramid/LOD${tileLOD}" 2> /dev/null
eval $command

echo "Generation is complete."

rm -rf /tmp/texture
