#!/bin/bash

echo "Preparing to build zone database..."

binDir=/vagrant/bin/linux
legendBox="ST_SetSRID(ST_MakeBox2D(ST_Point(0, 0), ST_Point(10000, 10000)), 27700)"

function removeOldLegend {
	psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
		DELETE FROM
			route
		WHERE
			route_id
		IN
		(
			SELECT
				relation_route_id
			FROM
				edge_route
			WHERE
				relation_edge_id
			IN
			(
				SELECT
					edge_id
				FROM
					edge
				WHERE
					edge_geom && ${legendBox}
			)
		);
		
		DELETE FROM
			edge_route
		WHERE
			relation_edge_id
		IN
		(
			SELECT
				edge_id
			FROM
				edge
			WHERE
				edge_geom && ${legendBox}
		);
		
		DELETE FROM elevation WHERE elevation_geom && ${legendBox};
		DELETE FROM surface WHERE surface_geom && ${legendBox};
		DELETE FROM buildings WHERE building_geom && ${legendBox};
		DELETE FROM edge WHERE edge_geom && ${legendBox};
		DELETE FROM zone WHERE zone_geom && ${legendBox};
		TRUNCATE TABLE legend_text;
EoSQL
}

textLineSpace=90
textLineEdgeAlign=20

patchSizeX=600
patchSizeY=300
patchBuffer=100
patchOriginX=3800
patchOriginY=$((9500 - ${patchSizeY}))

edgeBuffer=100
edgeSizeX=1800
edgeSizeY=50
edgeSizeYNamed=150
edgeSizeHalf=$((${edgeSizeX}/2))
edgeSizeCut=$((${edgeSizeX}/3))
edgeDualSpacing=9
edgeDualSpacingMotorway=10
edgeOriginX=500
edgeOriginY=$((9500 - ${edgeSizeY}/2))

# Patch sources
patchSourceContoursE=239074
patchSourceContoursN=585737
patchSourceCragsE=240301
patchSourceCragsN=581813
patchSourceWoodlandE=238800
patchSourceWoodlandN=582383
patchSourceWaterE=181000
patchSourceWaterN=35271
patchSourceBuildingE=90398
patchSourceBuildingN=10478

echo "-----------------------------------"
echo "--> Building legend..."
echo "-----------------------------------"

echo "--> Adding legend tile..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	DELETE FROM grid WHERE tile_name='LGND';
	INSERT INTO
		grid
		(tile_name, tile_geom)
	SELECT
		'LGND',
		${legendBox};
EoSQL

echo "--> Removing pre-existing legend data..."
removeOldLegend

echo "--> Adding new legend items..."

echo " -> Contour lines..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO
		elevation
		(elevation_level, elevation_geom)
	SELECT
		elevation_level,
		(ST_Dump(ST_Translate(
			ST_Translate(elevation_geom, -${patchSourceContoursE}, -${patchSourceContoursN}),
			${patchOriginX},
			${patchOriginY}
		))).geom AS elevation_geom
	FROM
	(
		SELECT
			elevation_level,
			ST_Intersection(elevation_geom, B.b) AS elevation_geom
		FROM
			( SELECT ST_SetSRID(ST_MakeBox2D(ST_Point(${patchSourceContoursE}, ${patchSourceContoursN}), ST_Point(${patchSourceContoursE} + ${patchSizeX}, ${patchSourceContoursN} + ${patchSizeY})), 27700) AS b ) B
		INNER JOIN
			elevation e
		ON
			e.elevation_geom && B.b
	) SA
	WHERE
		ST_NumGeometries(elevation_geom) > 0;
		
	INSERT INTO
		legend_text
		(text_geom, text_size, text_bold, text_italic, text_value)
	SELECT
		ST_SetSRID(ST_Point(${patchOriginX} + ${patchSizeX} + ${patchBuffer}, ${patchOriginY} + ${patchSizeY}), 27700),
		1,
		true,
		false,
		'Elevation contours';
		
	INSERT INTO
		legend_text
		(text_geom, text_size, text_bold, text_italic, text_value)
	SELECT
		ST_SetSRID(ST_Point(${patchOriginX} + ${patchSizeX} + ${patchBuffer}, ${patchOriginY} + ${patchSizeY} - ${textLineSpace}), 27700),
		1,
		false,
		false,
		'Emboldened at 50m intervals, shown at 10m or 5m intervals.';
EoSQL
patchOriginY=$((${patchOriginY} - ${patchBuffer} - ${patchSizeY}))

echo " -> Landform..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO
		surface
		(surface_class_id, surface_geom)
	SELECT
		surface_class_id,
		ST_Multi(ST_MakeValid(ST_Translate(
			ST_Translate(surface_geom, -${patchSourceCragsE}, -${patchSourceCragsN}),
			${patchOriginX},
			${patchOriginY}
		))) AS surface_geom
	FROM
	(
		SELECT
			surface_class_id,
			ST_Intersection(ST_MakeValid(surface_geom), B.b) AS surface_geom
		FROM
			( SELECT ST_SetSRID(ST_MakeBox2D(ST_Point(${patchSourceCragsE}, ${patchSourceCragsN}), ST_Point(${patchSourceCragsE} + ${patchSizeX}, ${patchSourceCragsN} + ${patchSizeY})), 27700) AS b ) B
		INNER JOIN
			surface e
		ON
			e.surface_geom && B.b
	) SA
	WHERE
		ST_NumGeometries(surface_geom) > 0;
		
	INSERT INTO
		legend_text
		(text_geom, text_size, text_bold, text_italic, text_value)
	SELECT
		ST_SetSRID(ST_Point(${patchOriginX} + ${patchSizeX} + ${patchBuffer}, ${patchOriginY} + ${patchSizeY}), 27700),
		1,
		true,
		false,
		'Landform';
		
	INSERT INTO
		legend_text
		(text_geom, text_size, text_bold, text_italic, text_value)
	SELECT
		ST_SetSRID(ST_Point(${patchOriginX} + ${patchSizeX} + ${patchBuffer}, ${patchOriginY} + ${patchSizeY} - ${textLineSpace}), 27700),
		1,
		false,
		false,
		'Includes crags, expanses of rock and cliffs.';
EoSQL
patchOriginY=$((${patchOriginY} - ${patchBuffer} - ${patchSizeY}))

echo " -> Woodland..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO
		surface
		(surface_class_id, surface_geom)
	SELECT
		surface_class_id,
		ST_Multi(ST_MakeValid(ST_Translate(
			ST_Translate(surface_geom, -${patchSourceWoodlandE}, -${patchSourceWoodlandN}),
			${patchOriginX},
			${patchOriginY}
		))) AS surface_geom
	FROM
	(
		SELECT
			surface_class_id,
			ST_Intersection(ST_MakeValid(surface_geom), B.b) AS surface_geom
		FROM
			( SELECT ST_SetSRID(ST_MakeBox2D(ST_Point(${patchSourceWoodlandE}, ${patchSourceWoodlandN}), ST_Point(${patchSourceWoodlandE} + ${patchSizeX}, ${patchSourceWoodlandN} + ${patchSizeY})), 27700) AS b ) B
		INNER JOIN
			surface e
		ON
			e.surface_geom && B.b
	) SA
	WHERE
		ST_NumGeometries(surface_geom) > 0;
		
	INSERT INTO
		legend_text
		(text_geom, text_size, text_bold, text_italic, text_value)
	SELECT
		ST_SetSRID(ST_Point(${patchOriginX} + ${patchSizeX} + ${patchBuffer}, ${patchOriginY} + ${patchSizeY}), 27700),
		1,
		true,
		false,
		'Woodland';
	INSERT INTO
		legend_text
		(text_geom, text_size, text_bold, text_italic, text_value)
	SELECT
		ST_SetSRID(ST_Point(${patchOriginX} + ${patchSizeX} + ${patchBuffer}, ${patchOriginY} + ${patchSizeY} - ${textLineSpace}), 27700),
		1,
		false,
		false,
		'Gaps are not indicative of path unless otherwise indicated.';
EoSQL
patchOriginY=$((${patchOriginY} - ${patchBuffer} - ${patchSizeY}))

echo " -> Water..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO
		surface
		(surface_class_id, surface_geom)
	SELECT
		surface_class_id,
		ST_Multi(ST_MakeValid(ST_Translate(
			ST_Translate(surface_geom, -${patchSourceWaterE}, -${patchSourceWaterN}),
			${patchOriginX},
			${patchOriginY}
		))) AS surface_geom
	FROM
	(
		SELECT
			surface_class_id,
			ST_Intersection(ST_MakeValid(surface_geom), B.b) AS surface_geom
		FROM
			( SELECT ST_SetSRID(ST_MakeBox2D(ST_Point(${patchSourceWaterE}, ${patchSourceWaterN}), ST_Point(${patchSourceWaterE} + ${patchSizeX}, ${patchSourceWaterN} + ${patchSizeY})), 27700) AS b ) B
		INNER JOIN
			surface e
		ON
			e.surface_geom && B.b
	) SA
	WHERE
		ST_NumGeometries(surface_geom) > 0;
		
	INSERT INTO
		legend_text
		(text_geom, text_size, text_bold, text_italic, text_value)
	SELECT
		ST_SetSRID(ST_Point(${patchOriginX} + ${patchSizeX} + ${patchBuffer}, ${patchOriginY} + ${patchSizeY}), 27700),
		1,
		true,
		false,
		'Tidal water';
		
	INSERT INTO
		legend_text
		(text_geom, text_size, text_bold, text_italic, text_value)
	SELECT
		ST_SetSRID(ST_Point(${patchOriginX} + ${patchSizeX} + ${patchBuffer}, ${patchOriginY} + ${patchSizeY} - ${textLineSpace}), 27700),
		1,
		false,
		false,
		'Foreshore shown will be submerged at high tide.';
EoSQL
patchOriginY=$((${patchOriginY} - ${patchBuffer} - ${patchSizeY}))

echo " -> Buildings..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO
		buildings
		(building_geom, building_layer)
	SELECT
		ST_Multi(ST_MakeValid(ST_Translate(
			ST_Translate(building_geom, -${patchSourceBuildingE}, -${patchSourceBuildingN}),
			${patchOriginX},
			${patchOriginY}
		))) AS building_geom,
		0 AS building_layer
	FROM
	(
		SELECT
			ST_Intersection(ST_MakeValid(building_geom), B.b) AS building_geom
		FROM
			( SELECT ST_SetSRID(ST_MakeBox2D(ST_Point(${patchSourceBuildingE}, ${patchSourceBuildingN}), ST_Point(${patchSourceBuildingE} + ${patchSizeX}, ${patchSourceBuildingN} + ${patchSizeY})), 27700) AS b ) B
		INNER JOIN
			buildings e
		ON
			e.building_geom && B.b
	) SA
	WHERE
		ST_NumGeometries(building_geom) > 0;
		
	INSERT INTO
		legend_text
		(text_geom, text_size, text_bold, text_italic, text_value)
	SELECT
		ST_SetSRID(ST_Point(${patchOriginX} + ${patchSizeX} + ${patchBuffer}, ${patchOriginY} + ${patchSizeY}), 27700),
		1,
		true,
		false,
		'Buildings';
		
	INSERT INTO
		legend_text
		(text_geom, text_size, text_bold, text_italic, text_value)
	SELECT
		ST_SetSRID(ST_Point(${patchOriginX} + ${patchSizeX} + ${patchBuffer}, ${patchOriginY} + ${patchSizeY} - ${textLineSpace}), 27700),
		1,
		false,
		false,
		'Some smaller structures may be omitted.';
EoSQL
patchOriginY=$((${patchOriginY} - ${patchBuffer} - ${patchSizeY}))

echo " -> CRoW Layer..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO
		zone
		(zone_class_id, zone_geom)
	SELECT
		1,
		ST_Multi(ST_SetSRID(ST_MakeBox2D(ST_Point(${patchOriginX}, ${patchOriginY}), ST_Point(${patchOriginX} + ${patchSizeX}, ${patchOriginY} + ${patchSizeY})), 27700));
		
	INSERT INTO
		legend_text
		(text_geom, text_size, text_bold, text_italic, text_value)
	SELECT
		ST_SetSRID(ST_Point(${patchOriginX} + ${patchSizeX} + ${patchBuffer}, ${patchOriginY} + ${patchSizeY}), 27700),
		1,
		true,
		false,
		'Access land';
		
	INSERT INTO
		legend_text
		(text_geom, text_size, text_bold, text_italic, text_value)
	SELECT
		ST_SetSRID(ST_Point(${patchOriginX} + ${patchSizeX} + ${patchBuffer}, ${patchOriginY} + ${patchSizeY} - ${textLineSpace}), 27700),
		1,
		false,
		false,
		'Access on foot is permitted under the Countryside and Rights of Way Act 2000.';
EoSQL
patchOriginY=$((${patchOriginY} - ${patchBuffer} - ${patchSizeY}))


##------------------------
## Edges
##------------------------

echo " -> Motorway..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO
		edge
		(edge_name, edge_class_id, edge_access_id, edge_geom, edge_tunnel, edge_slip, edge_bridge, edge_roundabout, edge_oneway, edge_level)
	SELECT
		'M1',	-- Name
		1,		-- Class
		1,		-- Access
		(ST_Dump(ST_SetSRID(ST_Collect(ARRAY[
			ST_MakeLine(ST_Point(${edgeOriginX}, ${edgeOriginY}), ST_Point(${edgeOriginX} + ${edgeSizeHalf}, ${edgeOriginY})),
			ST_MakeLine(ST_Point(${edgeOriginX}, ${edgeOriginY} - ${edgeDualSpacingMotorway}), ST_Point(${edgeOriginX} + ${edgeSizeHalf}, ${edgeOriginY} - ${edgeDualSpacingMotorway})),
			ST_MakeLine(ST_Point(${edgeOriginX} + ${edgeSizeHalf}, ${edgeOriginY}), ST_Point(${edgeOriginX} + ${edgeSizeX}, ${edgeOriginY})),
			ST_MakeLine(ST_Point(${edgeOriginX} + ${edgeSizeHalf}, ${edgeOriginY} - ${edgeDualSpacingMotorway}), ST_Point(${edgeOriginX} + ${edgeSizeX}, ${edgeOriginY} - ${edgeDualSpacingMotorway}))
		]), 27700))).geom,
		false,	-- Tunnel
		false,	-- Slip
		false,	-- Bridge
		false,	-- Roundabout
		true,	-- One way
		0;		-- Level
		
	INSERT INTO
		legend_text
		(text_geom, text_size, text_bold, text_italic, text_value)
	SELECT
		ST_SetSRID(ST_Point(${edgeOriginX} + ${edgeSizeX} + ${edgeBuffer}, ${edgeOriginY} + ${edgeSizeY}), 27700),
		1,
		true,
		false,
		'Motorway';
	INSERT INTO
		legend_text
		(text_geom, text_size, text_bold, text_italic, text_value)
	SELECT
		ST_SetSRID(ST_Point(${edgeOriginX} + ${edgeSizeX} + ${edgeBuffer}, ${edgeOriginY} + ${edgeSizeY} - ${textLineSpace}), 27700),
		1,
		false,
		false,
		'Centre dashes indicate dual-carriageway. No pedestrian or bicycle access.';
EoSQL
edgeOriginY=$((${edgeOriginY} - ${edgeBuffer} - ${edgeSizeYNamed}))

echo " -> Primary routes..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO
		edge
		(edge_name, edge_class_id, edge_access_id, edge_geom, edge_tunnel, edge_slip, edge_bridge, edge_roundabout, edge_oneway, edge_level)
	SELECT
		'A1',-- Name
		2,		-- Class
		1,		-- Access
		(ST_Dump(ST_SetSRID(ST_Collect(ARRAY[
			ST_MakeLine(ST_Point(${edgeOriginX}, ${edgeOriginY}), ST_Point(${edgeOriginX} + ${edgeSizeHalf}, ${edgeOriginY})),
			ST_MakeLine(ST_Point(${edgeOriginX}, ${edgeOriginY} - ${edgeDualSpacing}), ST_Point(${edgeOriginX} + ${edgeSizeHalf}, ${edgeOriginY} - ${edgeDualSpacing})),
			ST_MakeLine(ST_Point(${edgeOriginX} + ${edgeSizeHalf}, ${edgeOriginY}), ST_Point(${edgeOriginX} + ${edgeSizeX}, ${edgeOriginY})),
			ST_MakeLine(ST_Point(${edgeOriginX} + ${edgeSizeHalf}, ${edgeOriginY} - ${edgeDualSpacing}), ST_Point(${edgeOriginX} + ${edgeSizeX}, ${edgeOriginY} - ${edgeDualSpacing}))
		]), 27700))).geom,
		false,	-- Tunnel
		false,	-- Slip
		false,	-- Bridge
		false,	-- Roundabout
		true,	-- One way
		0;		-- Level
		
	INSERT INTO
		legend_text
		(text_geom, text_size, text_bold, text_italic, text_value)
	SELECT
		ST_SetSRID(ST_Point(${edgeOriginX} + ${edgeSizeX} + ${edgeBuffer}, ${edgeOriginY} + ${edgeSizeY}), 27700),
		1,
		true,
		false,
		'Primary road (dual carriageway)';
	INSERT INTO
		legend_text
		(text_geom, text_size, text_bold, text_italic, text_value)
	SELECT
		ST_SetSRID(ST_Point(${edgeOriginX} + ${edgeSizeX} + ${edgeBuffer}, ${edgeOriginY} + ${edgeSizeY} - ${textLineSpace}), 27700),
		1,
		false,
		false,
		'Dual-carriageway primary route as defined in the Highway Code.';
EoSQL
edgeOriginY=$((${edgeOriginY} - ${edgeBuffer} - ${edgeSizeYNamed}))

echo " -> Primary road (single)..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO
		edge
		(edge_name, edge_class_id, edge_access_id, edge_geom, edge_tunnel, edge_slip, edge_bridge, edge_roundabout, edge_oneway, edge_level)
	SELECT
		'A2', 	-- Name
		2,		-- Class
		1,		-- Access
		(ST_Dump(ST_SetSRID(ST_Collect(ARRAY[
			ST_MakeLine(ST_Point(${edgeOriginX}, ${edgeOriginY}), ST_Point(${edgeOriginX} + ${edgeSizeHalf}, ${edgeOriginY})),
			ST_MakeLine(ST_Point(${edgeOriginX} + ${edgeSizeHalf}, ${edgeOriginY}), ST_Point(${edgeOriginX} + ${edgeSizeX}, ${edgeOriginY}))
		]), 27700))).geom,
		false,	-- Tunnel
		false,	-- Slip
		false,	-- Bridge
		false,	-- Roundabout
		false,	-- One way
		0;		-- Level
		
	INSERT INTO
		legend_text
		(text_geom, text_size, text_bold, text_italic, text_value)
	SELECT
		ST_SetSRID(ST_Point(${edgeOriginX} + ${edgeSizeX} + ${edgeBuffer}, ${edgeOriginY} + ${edgeSizeY}), 27700),
		1,
		true,
		false,
		'Primary road (single carriageway)';
	INSERT INTO
		legend_text
		(text_geom, text_size, text_bold, text_italic, text_value)
	SELECT
		ST_SetSRID(ST_Point(${edgeOriginX} + ${edgeSizeX} + ${edgeBuffer}, ${edgeOriginY} + ${edgeSizeY} - ${textLineSpace}), 27700),
		1,
		false,
		false,
		'Single-carriageway primary route as defined in the Highway Code.';
EoSQL
edgeOriginY=$((${edgeOriginY} - ${edgeBuffer} - ${edgeSizeYNamed}))

echo " -> A road..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO
		edge
		(edge_name, edge_class_id, edge_access_id, edge_geom, edge_tunnel, edge_slip, edge_bridge, edge_roundabout, edge_oneway, edge_level)
	SELECT
		'A3',	-- Name
		3,		-- Class
		1,		-- Access
		(ST_Dump(ST_SetSRID(ST_Collect(ARRAY[
			ST_MakeLine(ST_Point(${edgeOriginX}, ${edgeOriginY}), ST_Point(${edgeOriginX} + ${edgeSizeHalf}, ${edgeOriginY})),
			ST_MakeLine(ST_Point(${edgeOriginX} + ${edgeSizeHalf}, ${edgeOriginY}), ST_Point(${edgeOriginX} + ${edgeSizeX}, ${edgeOriginY}))
		]), 27700))).geom,
		false,	-- Tunnel
		false,	-- Slip
		false,	-- Bridge
		false,	-- Roundabout
		false,	-- One way
		0;		-- Level
	INSERT INTO
		legend_text
		(text_geom, text_size, text_bold, text_italic, text_value)
	SELECT
		ST_SetSRID(ST_Point(${edgeOriginX} + ${edgeSizeX} + ${edgeBuffer}, ${edgeOriginY} + ${edgeSizeY} - ${textLineEdgeAlign}), 27700),
		1,
		true,
		false,
		'A road';
EoSQL
edgeOriginY=$((${edgeOriginY} - ${edgeBuffer} - ${edgeSizeYNamed}))

echo " -> B road..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO
		edge
		(edge_name, edge_class_id, edge_access_id, edge_geom, edge_tunnel, edge_slip, edge_bridge, edge_roundabout, edge_oneway, edge_level)
	SELECT
		'B100',	-- Name
		4,		-- Class
		1,		-- Access
		(ST_Dump(ST_SetSRID(ST_Collect(ARRAY[
			ST_MakeLine(ST_Point(${edgeOriginX}, ${edgeOriginY}), ST_Point(${edgeOriginX} + ${edgeSizeHalf}, ${edgeOriginY})),
			ST_MakeLine(ST_Point(${edgeOriginX} + ${edgeSizeHalf}, ${edgeOriginY}), ST_Point(${edgeOriginX} + ${edgeSizeX}, ${edgeOriginY}))
		]), 27700))).geom,
		false,	-- Tunnel
		false,	-- Slip
		false,	-- Bridge
		false,	-- Roundabout
		false,	-- One way
		0;		-- Level
	INSERT INTO
		legend_text
		(text_geom, text_size, text_bold, text_italic, text_value)
	SELECT
		ST_SetSRID(ST_Point(${edgeOriginX} + ${edgeSizeX} + ${edgeBuffer}, ${edgeOriginY} + ${edgeSizeY} - ${textLineEdgeAlign}), 27700),
		1,
		true,
		false,
		'B road';
EoSQL
edgeOriginY=$((${edgeOriginY} - ${edgeBuffer} - ${edgeSizeYNamed}))

echo " -> Local street..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO
		edge
		(edge_name, edge_class_id, edge_access_id, edge_geom, edge_tunnel, edge_slip, edge_bridge, edge_roundabout, edge_oneway, edge_level)
	SELECT
		'Street Name', -- Name
		5,		-- Class
		1,		-- Access
		ST_SetSRID(ST_MakeLine(ST_Point(${edgeOriginX}, ${edgeOriginY}), ST_Point(${edgeOriginX} + ${edgeSizeX}, ${edgeOriginY})), 27700),
		false,	-- Tunnel
		false,	-- Slip
		false,	-- Bridge
		false,	-- Roundabout
		false,	-- One way
		0;		-- Level
	INSERT INTO
		legend_text
		(text_geom, text_size, text_bold, text_italic, text_value)
	SELECT
		ST_SetSRID(ST_Point(${edgeOriginX} + ${edgeSizeX} + ${edgeBuffer}, ${edgeOriginY} + ${edgeSizeY} - ${textLineEdgeAlign}), 27700),
		1,
		true,
		false,
		'Local street';
EoSQL
edgeOriginY=$((${edgeOriginY} - ${edgeBuffer} - ${edgeSizeYNamed}))

echo " -> Minor road..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO
		edge
		(edge_name, edge_class_id, edge_access_id, edge_geom, edge_tunnel, edge_slip, edge_bridge, edge_roundabout, edge_oneway, edge_level)
	SELECT
		'Road Name',	-- Name
		6,		-- Class
		1,		-- Access
		ST_SetSRID(ST_MakeLine(ST_Point(${edgeOriginX}, ${edgeOriginY}), ST_Point(${edgeOriginX} + ${edgeSizeX}, ${edgeOriginY})), 27700),
		false,	-- Tunnel
		false,	-- Slip
		false,	-- Bridge
		false,	-- Roundabout
		false,	-- One way
		0;		-- Level
	INSERT INTO
		legend_text
		(text_geom, text_size, text_bold, text_italic, text_value)
	SELECT
		ST_SetSRID(ST_Point(${edgeOriginX} + ${edgeSizeX} + ${edgeBuffer}, ${edgeOriginY} + ${edgeSizeY} - ${textLineEdgeAlign}), 27700),
		1,
		true,
		false,
		'Minor road';
EoSQL
edgeOriginY=$((${edgeOriginY} - ${edgeBuffer} - ${edgeSizeY}))

echo " -> Service road..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO
		edge
		(edge_name, edge_class_id, edge_access_id, edge_geom, edge_tunnel, edge_slip, edge_bridge, edge_roundabout, edge_oneway, edge_level)
	SELECT
		'',		-- Name
		7,		-- Class
		1,		-- Access
		ST_SetSRID(ST_MakeLine(ST_Point(${edgeOriginX}, ${edgeOriginY}), ST_Point(${edgeOriginX} + ${edgeSizeX}, ${edgeOriginY})), 27700),
		false,	-- Tunnel
		false,	-- Slip
		false,	-- Bridge
		false,	-- Roundabout
		false,	-- One way
		0;		-- Level
	INSERT INTO
		legend_text
		(text_geom, text_size, text_bold, text_italic, text_value)
	SELECT
		ST_SetSRID(ST_Point(${edgeOriginX} + ${edgeSizeX} + ${edgeBuffer}, ${edgeOriginY} + ${edgeSizeY} - ${textLineEdgeAlign}), 27700),
		1,
		true,
		false,
		'Service road';
EoSQL
edgeOriginY=$((${edgeOriginY} - ${edgeBuffer} - ${edgeSizeYNamed}))

echo " -> Track..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO
		edge
		(edge_name, edge_class_id, edge_access_id, edge_geom, edge_tunnel, edge_slip, edge_bridge, edge_roundabout, edge_oneway, edge_level)
	SELECT
		'Track name',	-- Name
		8,		-- Class
		1,		-- Access
		ST_SetSRID(ST_MakeLine(ST_Point(${edgeOriginX}, ${edgeOriginY}), ST_Point(${edgeOriginX} + ${edgeSizeX}, ${edgeOriginY})), 27700),
		false,	-- Tunnel
		false,	-- Slip
		false,	-- Bridge
		false,	-- Roundabout
		false,	-- One way
		0;		-- Level
	INSERT INTO
		legend_text
		(text_geom, text_size, text_bold, text_italic, text_value)
	SELECT
		ST_SetSRID(ST_Point(${edgeOriginX} + ${edgeSizeX} + ${edgeBuffer}, ${edgeOriginY} + ${edgeSizeY}), 27700),
		1,
		true,
		false,
		'Track';
	INSERT INTO
		legend_text
		(text_geom, text_size, text_bold, text_italic, text_value)
	SELECT
		ST_SetSRID(ST_Point(${edgeOriginX} + ${edgeSizeX} + ${edgeBuffer}, ${edgeOriginY} + ${edgeSizeY} - ${textLineSpace}), 27700),
		1,
		false,
		false,
		'Access may be limited for motor cars.';
EoSQL
edgeOriginY=$((${edgeOriginY} - ${edgeBuffer} - ${edgeSizeYNamed}))

echo " -> Under construction (A road)..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO
		edge
		(edge_name, edge_class_id, edge_access_id, edge_geom, edge_tunnel, edge_slip, edge_bridge, edge_roundabout, edge_oneway, edge_level)
	SELECT
		'',		-- Name
		2,		-- Class
		13,		-- Access
		ST_SetSRID(ST_MakeLine(ST_Point(${edgeOriginX}, ${edgeOriginY}), ST_Point(${edgeOriginX} + ${edgeSizeX}, ${edgeOriginY})), 27700),
		false,	-- Tunnel
		false,	-- Slip
		false,	-- Bridge
		false,	-- Roundabout
		false,	-- One way
		0;		-- Level
	INSERT INTO
		legend_text
		(text_geom, text_size, text_bold, text_italic, text_value)
	SELECT
		ST_SetSRID(ST_Point(${edgeOriginX} + ${edgeSizeX} + ${edgeBuffer}, ${edgeOriginY} + ${edgeSizeY}), 27700),
		1,
		true,
		false,
		'Under construction';
	INSERT INTO
		legend_text
		(text_geom, text_size, text_bold, text_italic, text_value)
	SELECT
		ST_SetSRID(ST_Point(${edgeOriginX} + ${edgeSizeX} + ${edgeBuffer}, ${edgeOriginY} + ${edgeSizeY} - ${textLineSpace}), 27700),
		1,
		false,
		false,
		'Dashed style applicable to all classifications.';
EoSQL
edgeOriginY=$((${edgeOriginY} - ${edgeBuffer} - ${edgeSizeYNamed}))

echo " -> Pedestrianised minor road..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO
		edge
		(edge_name, edge_class_id, edge_access_id, edge_geom, edge_tunnel, edge_slip, edge_bridge, edge_roundabout, edge_oneway, edge_level)
	SELECT
		'',		-- Name
		6,		-- Class
		7,		-- Access
		ST_SetSRID(ST_MakeLine(ST_Point(${edgeOriginX}, ${edgeOriginY}), ST_Point(${edgeOriginX} + ${edgeSizeX}, ${edgeOriginY})), 27700),
		false,	-- Tunnel
		false,	-- Slip
		false,	-- Bridge
		false,	-- Roundabout
		false,	-- One way
		0;		-- Level
	INSERT INTO
		legend_text
		(text_geom, text_size, text_bold, text_italic, text_value)
	SELECT
		ST_SetSRID(ST_Point(${edgeOriginX} + ${edgeSizeX} + ${edgeBuffer}, ${edgeOriginY} + ${edgeSizeY}), 27700),
		1,
		true,
		false,
		'Pedestrianised street';
	INSERT INTO
		legend_text
		(text_geom, text_size, text_bold, text_italic, text_value)
	SELECT
		ST_SetSRID(ST_Point(${edgeOriginX} + ${edgeSizeX} + ${edgeBuffer}, ${edgeOriginY} + ${edgeSizeY} - ${textLineSpace}), 27700),
		1,
		false,
		false,
		'Motor vehicle and bicycle access may be restricted.';
EoSQL
edgeOriginY=$((${edgeOriginY} - ${edgeBuffer} - ${edgeSizeYNamed}))

echo " -> Railway..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO
		edge
		(edge_name, edge_class_id, edge_access_id, edge_geom, edge_tunnel, edge_slip, edge_bridge, edge_roundabout, edge_oneway, edge_level)
	SELECT
		'East Coast Mainline', -- Name
		13,		-- Class
		9,		-- Access
		ST_SetSRID(ST_MakeLine(ST_Point(${edgeOriginX}, ${edgeOriginY}), ST_Point(${edgeOriginX} + ${edgeSizeX}, ${edgeOriginY})), 27700),
		false,	-- Tunnel
		false,	-- Slip
		false,	-- Bridge
		false,	-- Roundabout
		false,	-- One way
		0;		-- Level
	INSERT INTO
		legend_text
		(text_geom, text_size, text_bold, text_italic, text_value)
	SELECT
		ST_SetSRID(ST_Point(${edgeOriginX} + ${edgeSizeX} + ${edgeBuffer}, ${edgeOriginY} + ${edgeSizeY} - ${textLineEdgeAlign}), 27700),
		1,
		true,
		false,
		'Railway line';
EoSQL
edgeOriginY=$((${edgeOriginY} - ${edgeBuffer} - ${edgeSizeY}))

# -- Separator
edgeOriginY=$((${edgeOriginY} - ${edgeBuffer}))

echo " -> Bridge..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO
		edge
		(edge_name, edge_class_id, edge_access_id, edge_geom, edge_tunnel, edge_slip, edge_bridge, edge_roundabout, edge_oneway, edge_level)
	SELECT
		NULL,	-- Name
		3,		-- Class
		1,		-- Access
		(ST_Dump(ST_SetSRID(ST_Collect(ARRAY[
			ST_MakeLine(ST_Point(${edgeOriginX}, ${edgeOriginY}), ST_Point(${edgeOriginX} + ${edgeSizeCut}, ${edgeOriginY})),
			ST_MakeLine(ST_Point(${edgeOriginX} + ${edgeSizeX} - ${edgeSizeCut}, ${edgeOriginY}), ST_Point(${edgeOriginX} + ${edgeSizeX}, ${edgeOriginY}))
		]), 27700))).geom,
		false,	-- Tunnel
		false,	-- Slip
		false,	-- Bridge
		false,	-- Roundabout
		false,	-- One way
		0;		-- Level
	INSERT INTO
		edge
		(edge_name, edge_class_id, edge_access_id, edge_geom, edge_tunnel, edge_slip, edge_bridge, edge_roundabout, edge_oneway, edge_level)
	SELECT
		'Bridge (A1)',	-- Name
		3,		-- Class
		1,		-- Access
		ST_SetSRID(ST_MakeLine(ST_Point(${edgeOriginX} + ${edgeSizeCut}, ${edgeOriginY}), ST_Point(${edgeOriginX} + ${edgeSizeX} - ${edgeSizeCut}, ${edgeOriginY})), 27700),
		false,	-- Tunnel
		false,	-- Slip
		true,	-- Bridge
		false,	-- Roundabout
		false,	-- One way
		0;		-- Level
	INSERT INTO
		legend_text
		(text_geom, text_size, text_bold, text_italic, text_value)
	SELECT
		ST_SetSRID(ST_Point(${edgeOriginX} + ${edgeSizeX} + ${edgeBuffer}, ${edgeOriginY} + ${edgeSizeY} - ${textLineEdgeAlign}), 27700),
		1,
		true,
		false,
		'Bridge or elevated road';
EoSQL
edgeOriginY=$((${edgeOriginY} - ${edgeBuffer} - ${edgeSizeY}))

echo " -> Tunnel..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO
		edge
		(edge_name, edge_class_id, edge_access_id, edge_geom, edge_tunnel, edge_slip, edge_bridge, edge_roundabout, edge_oneway, edge_level)
	SELECT
		NULL,	-- Name
		3,		-- Class
		1,		-- Access
		(ST_Dump(ST_SetSRID(ST_Collect(ARRAY[
			ST_MakeLine(ST_Point(${edgeOriginX}, ${edgeOriginY}), ST_Point(${edgeOriginX} + ${edgeSizeCut}, ${edgeOriginY})),
			ST_MakeLine(ST_Point(${edgeOriginX} + ${edgeSizeX} - ${edgeSizeCut}, ${edgeOriginY}), ST_Point(${edgeOriginX} + ${edgeSizeX}, ${edgeOriginY}))
		]), 27700))).geom,
		false,	-- Tunnel
		false,	-- Slip
		false,	-- Bridge
		false,	-- Roundabout
		false,	-- One way
		0;		-- Level
	INSERT INTO
		edge
		(edge_name, edge_class_id, edge_access_id, edge_geom, edge_tunnel, edge_slip, edge_bridge, edge_roundabout, edge_oneway, edge_level)
	SELECT
		'Tunnel (A1)',	-- Name
		3,		-- Class
		1,		-- Access
		ST_SetSRID(ST_MakeLine(ST_Point(${edgeOriginX} + ${edgeSizeCut}, ${edgeOriginY}), ST_Point(${edgeOriginX} + ${edgeSizeX} - ${edgeSizeCut}, ${edgeOriginY})), 27700),
		true,	-- Tunnel
		false,	-- Slip
		false,	-- Bridge
		false,	-- Roundabout
		false,	-- One way
		0;		-- Level
	INSERT INTO
		legend_text
		(text_geom, text_size, text_bold, text_italic, text_value)
	SELECT
		ST_SetSRID(ST_Point(${edgeOriginX} + ${edgeSizeX} + ${edgeBuffer}, ${edgeOriginY} + ${edgeSizeY} - ${textLineEdgeAlign}), 27700),
		1,
		true,
		false,
		'Tunnel';
EoSQL
edgeOriginY=$((${edgeOriginY} - ${edgeBuffer} - ${edgeSizeY}))

# -- Separator
edgeOriginY=$((${edgeOriginY} - ${edgeBuffer}))

echo " -> Legal footpath..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO
		edge
		(edge_name, edge_class_id, edge_access_id, edge_geom, edge_tunnel, edge_slip, edge_bridge, edge_roundabout, edge_oneway, edge_level)
	SELECT
		'',	-- Name
		10,		-- Class
		4,		-- Access
		ST_SetSRID(ST_MakeLine(ST_Point(${edgeOriginX}, ${edgeOriginY}), ST_Point(${edgeOriginX} + ${edgeSizeX}, ${edgeOriginY})), 27700),
		false,	-- Tunnel
		false,	-- Slip
		false,	-- Bridge
		false,	-- Roundabout
		false,	-- One way
		0;		-- Level
	INSERT INTO
		legend_text
		(text_geom, text_size, text_bold, text_italic, text_value)
	SELECT
		ST_SetSRID(ST_Point(${edgeOriginX} + ${edgeSizeX} + ${edgeBuffer}, ${edgeOriginY} + ${edgeSizeY}), 27700),
		1,
		true,
		false,
		'Public footpath or maintained footway';
	INSERT INTO
		legend_text
		(text_geom, text_size, text_bold, text_italic, text_value)
	SELECT
		ST_SetSRID(ST_Point(${edgeOriginX} + ${edgeSizeX} + ${edgeBuffer}, ${edgeOriginY} + ${edgeSizeY} - ${textLineSpace}), 27700),
		1,
		false,
		false,
		'A legal right of way or a route actively maintained for pedestrian access.';
EoSQL
edgeOriginY=$((${edgeOriginY} - ${edgeBuffer} - ${edgeSizeYNamed}))

echo " -> Permissive footpath..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO
		edge
		(edge_name, edge_class_id, edge_access_id, edge_geom, edge_tunnel, edge_slip, edge_bridge, edge_roundabout, edge_oneway, edge_level)
	SELECT
		'',	-- Name
		10,		-- Class
		5,		-- Access
		ST_SetSRID(ST_MakeLine(ST_Point(${edgeOriginX}, ${edgeOriginY}), ST_Point(${edgeOriginX} + ${edgeSizeX}, ${edgeOriginY})), 27700),
		false,	-- Tunnel
		false,	-- Slip
		false,	-- Bridge
		false,	-- Roundabout
		false,	-- One way
		0;		-- Level
	INSERT INTO
		legend_text
		(text_geom, text_size, text_bold, text_italic, text_value)
	SELECT
		ST_SetSRID(ST_Point(${edgeOriginX} + ${edgeSizeX} + ${edgeBuffer}, ${edgeOriginY} + ${edgeSizeY}), 27700),
		1,
		true,
		false,
		'Permissive footpath';
	INSERT INTO
		legend_text
		(text_geom, text_size, text_bold, text_italic, text_value)
	SELECT
		ST_SetSRID(ST_Point(${edgeOriginX} + ${edgeSizeX} + ${edgeBuffer}, ${edgeOriginY} + ${edgeSizeY} - ${textLineSpace}), 27700),
		1,
		false,
		false,
		'Access is not guaranteed but usually permitted by the landowner.';
EoSQL
edgeOriginY=$((${edgeOriginY} - ${edgeBuffer} - ${edgeSizeYNamed}))

echo " -> Other footpath..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO
		edge
		(edge_name, edge_class_id, edge_access_id, edge_geom, edge_tunnel, edge_slip, edge_bridge, edge_roundabout, edge_oneway, edge_level)
	SELECT
		'',	-- Name
		10,		-- Class
		3,		-- Access
		ST_SetSRID(ST_MakeLine(ST_Point(${edgeOriginX}, ${edgeOriginY}), ST_Point(${edgeOriginX} + ${edgeSizeX}, ${edgeOriginY})), 27700),
		false,	-- Tunnel
		false,	-- Slip
		false,	-- Bridge
		false,	-- Roundabout
		false,	-- One way
		0;		-- Level
	INSERT INTO
		legend_text
		(text_geom, text_size, text_bold, text_italic, text_value)
	SELECT
		ST_SetSRID(ST_Point(${edgeOriginX} + ${edgeSizeX} + ${edgeBuffer}, ${edgeOriginY} + ${edgeSizeY} - ${textLineEdgeAlign}), 27700),
		1,
		true,
		false,
		'Other footpath';
EoSQL
edgeOriginY=$((${edgeOriginY} - ${edgeBuffer} - ${edgeSizeY}))

echo " -> Bridleway or cycle path..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO
		edge
		(edge_name, edge_class_id, edge_access_id, edge_geom, edge_tunnel, edge_slip, edge_bridge, edge_roundabout, edge_oneway, edge_level)
	SELECT
		'',	-- Name
		10,		-- Class
		8,		-- Access
		ST_SetSRID(ST_MakeLine(ST_Point(${edgeOriginX}, ${edgeOriginY}), ST_Point(${edgeOriginX} + ${edgeSizeX}, ${edgeOriginY})), 27700),
		false,	-- Tunnel
		false,	-- Slip
		false,	-- Bridge
		false,	-- Roundabout
		false,	-- One way
		0;		-- Level
	INSERT INTO
		legend_text
		(text_geom, text_size, text_bold, text_italic, text_value)
	SELECT
		ST_SetSRID(ST_Point(${edgeOriginX} + ${edgeSizeX} + ${edgeBuffer}, ${edgeOriginY} + ${edgeSizeY}), 27700),
		1,
		true,
		false,
		'Public bridleway or cycle path';
	INSERT INTO
		legend_text
		(text_geom, text_size, text_bold, text_italic, text_value)
	SELECT
		ST_SetSRID(ST_Point(${edgeOriginX} + ${edgeSizeX} + ${edgeBuffer}, ${edgeOriginY} + ${edgeSizeY} - ${textLineSpace}), 27700),
		1,
		false,
		false,
		'Bicycles are permitted. May be shared with pedestrians.';
EoSQL
edgeOriginY=$((${edgeOriginY} - ${edgeBuffer} - ${edgeSizeYNamed}))

echo " -> Byway open to all traffic..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO
		edge
		(edge_name, edge_class_id, edge_access_id, edge_geom, edge_tunnel, edge_slip, edge_bridge, edge_roundabout, edge_oneway, edge_level)
	SELECT
		'',	-- Name
		8,		-- Class
		6,		-- Access
		ST_SetSRID(ST_MakeLine(ST_Point(${edgeOriginX}, ${edgeOriginY}), ST_Point(${edgeOriginX} + ${edgeSizeX}, ${edgeOriginY})), 27700),
		false,	-- Tunnel
		false,	-- Slip
		false,	-- Bridge
		false,	-- Roundabout
		false,	-- One way
		0;		-- Level
	INSERT INTO
		legend_text
		(text_geom, text_size, text_bold, text_italic, text_value)
	SELECT
		ST_SetSRID(ST_Point(${edgeOriginX} + ${edgeSizeX} + ${edgeBuffer}, ${edgeOriginY} + ${edgeSizeY}), 27700),
		1,
		true,
		false,
		'Byway open to all traffic';
	INSERT INTO
		legend_text
		(text_geom, text_size, text_bold, text_italic, text_value)
	SELECT
		ST_SetSRID(ST_Point(${edgeOriginX} + ${edgeSizeX} + ${edgeBuffer}, ${edgeOriginY} + ${edgeSizeY} - ${textLineSpace}), 27700),
		1,
		false,
		false,
		'Motor vehicles are permitted but road may not be surfaced.';
EoSQL
edgeOriginY=$((${edgeOriginY} - ${edgeBuffer} - ${edgeSizeYNamed}))

echo " -> Restricted byway..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO
		edge
		(edge_name, edge_class_id, edge_access_id, edge_geom, edge_tunnel, edge_slip, edge_bridge, edge_roundabout, edge_oneway, edge_level)
	SELECT
		'',	-- Name
		8,		-- Class
		10,		-- Access
		ST_SetSRID(ST_MakeLine(ST_Point(${edgeOriginX}, ${edgeOriginY}), ST_Point(${edgeOriginX} + ${edgeSizeX}, ${edgeOriginY})), 27700),
		false,	-- Tunnel
		false,	-- Slip
		false,	-- Bridge
		false,	-- Roundabout
		false,	-- One way
		0;		-- Level
	INSERT INTO
		legend_text
		(text_geom, text_size, text_bold, text_italic, text_value)
	SELECT
		ST_SetSRID(ST_Point(${edgeOriginX} + ${edgeSizeX} + ${edgeBuffer}, ${edgeOriginY} + ${edgeSizeY}), 27700),
		1,
		true,
		false,
		'Restricted byway';
	INSERT INTO
		legend_text
		(text_geom, text_size, text_bold, text_italic, text_value)
	SELECT
		ST_SetSRID(ST_Point(${edgeOriginX} + ${edgeSizeX} + ${edgeBuffer}, ${edgeOriginY} + ${edgeSizeY} - ${textLineSpace}), 27700),
		1,
		false,
		false,
		'Access on foot, bicycle and horse is permitted.';
EoSQL
edgeOriginY=$((${edgeOriginY} - ${edgeBuffer} - ${edgeSizeYNamed}))

# -- Separator
edgeOriginY=$((${edgeOriginY} - ${edgeBuffer}))

echo " -> National trail..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO
		edge
		(edge_name, edge_class_id, edge_access_id, edge_geom, edge_tunnel, edge_slip, edge_bridge, edge_roundabout, edge_oneway, edge_level)
	SELECT
		'',		-- Name
		10,		-- Class
		4,		-- Access
		(ST_Dump(ST_SetSRID(ST_Collect(ARRAY[
			ST_MakeLine(ST_Point(${edgeOriginX}, ${edgeOriginY}), ST_Point(${edgeOriginX} + ${edgeSizeHalf}, ${edgeOriginY})),
			ST_MakeLine(ST_Point(${edgeOriginX} + ${edgeSizeHalf}, ${edgeOriginY}), ST_Point(${edgeOriginX} + ${edgeSizeX}, ${edgeOriginY}))
		]), 27700))).geom,
		false,	-- Tunnel
		false,	-- Slip
		false,	-- Bridge
		false,	-- Roundabout
		false,	-- One way
		0;		-- Level
	INSERT INTO
		route
		(route_class_id, route_name)
	SELECT
		5,
		'National trail';
	INSERT INTO
		edge_route
		(relation_route_id, relation_edge_id)
	SELECT
		(SELECT route_id FROM route WHERE route_name = 'National trail'),
		edge_id
	FROM
		edge
	WHERE
		edge_geom && ST_Point(${edgeOriginX} + ${edgeSizeHalf}, ${edgeOriginY});
	INSERT INTO
		legend_text
		(text_geom, text_size, text_bold, text_italic, text_value)
	SELECT
		ST_SetSRID(ST_Point(${edgeOriginX} + ${edgeSizeX} + ${edgeBuffer}, ${edgeOriginY} + ${edgeSizeY} - ${textLineEdgeAlign}), 27700),
		1,
		true,
		false,
		'National trail for walking';
EoSQL
edgeOriginY=$((${edgeOriginY} - ${edgeBuffer} - ${edgeSizeY}))

echo " -> Regional trail..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO
		edge
		(edge_name, edge_class_id, edge_access_id, edge_geom, edge_tunnel, edge_slip, edge_bridge, edge_roundabout, edge_oneway, edge_level)
	SELECT
		'',		-- Name
		10,		-- Class
		4,		-- Access
		(ST_Dump(ST_SetSRID(ST_Collect(ARRAY[
			ST_MakeLine(ST_Point(${edgeOriginX}, ${edgeOriginY}), ST_Point(${edgeOriginX} + ${edgeSizeHalf}, ${edgeOriginY})),
			ST_MakeLine(ST_Point(${edgeOriginX} + ${edgeSizeHalf}, ${edgeOriginY}), ST_Point(${edgeOriginX} + ${edgeSizeX}, ${edgeOriginY}))
		]), 27700))).geom,
		false,	-- Tunnel
		false,	-- Slip
		false,	-- Bridge
		false,	-- Roundabout
		false,	-- One way
		0;		-- Level
	INSERT INTO
		route
		(route_class_id, route_name)
	SELECT
		6,
		'Regional trail';
	INSERT INTO
		edge_route
		(relation_route_id, relation_edge_id)
	SELECT
		(SELECT route_id FROM route WHERE route_name = 'Regional trail'),
		edge_id
	FROM
		edge
	WHERE
		edge_geom && ST_Point(${edgeOriginX} + ${edgeSizeHalf}, ${edgeOriginY});
		
	INSERT INTO
		legend_text
		(text_geom, text_size, text_bold, text_italic, text_value)
	SELECT
		ST_SetSRID(ST_Point(${edgeOriginX} + ${edgeSizeX} + ${edgeBuffer}, ${edgeOriginY} + ${edgeSizeY} - ${textLineEdgeAlign}), 27700),
		1,
		true,
		false,
		'Regional trail for walking';
EoSQL
edgeOriginY=$((${edgeOriginY} - ${edgeBuffer} - ${edgeSizeY}))

echo " -> National cycle network..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO
		edge
		(edge_name, edge_class_id, edge_access_id, edge_geom, edge_tunnel, edge_slip, edge_bridge, edge_roundabout, edge_oneway, edge_level)
	SELECT
		'',		-- Name
		10,		-- Class
		8,		-- Access
		(ST_Dump(ST_SetSRID(ST_Collect(ARRAY[
			ST_MakeLine(ST_Point(${edgeOriginX}, ${edgeOriginY}), ST_Point(${edgeOriginX} + ${edgeSizeHalf}, ${edgeOriginY})),
			ST_MakeLine(ST_Point(${edgeOriginX} + ${edgeSizeHalf}, ${edgeOriginY}), ST_Point(${edgeOriginX} + ${edgeSizeX}, ${edgeOriginY}))
		]), 27700))).geom,
		false,	-- Tunnel
		false,	-- Slip
		false,	-- Bridge
		false,	-- Roundabout
		false,	-- One way
		0;		-- Level
	INSERT INTO
		route
		(route_class_id, route_name, route_ref)
	SELECT
		1,
		'Coast to Coast',
		'999';
	INSERT INTO
		edge_route
		(relation_route_id, relation_edge_id)
	SELECT
		(SELECT route_id FROM route WHERE route_ref = '999' AND route_class_id=1),
		edge_id
	FROM
		edge
	WHERE
		edge_geom && ST_Point(${edgeOriginX} + ${edgeSizeHalf}, ${edgeOriginY});
		
	INSERT INTO
		legend_text
		(text_geom, text_size, text_bold, text_italic, text_value)
	SELECT
		ST_SetSRID(ST_Point(${edgeOriginX} + ${edgeSizeX} + ${edgeBuffer}, ${edgeOriginY} + ${edgeSizeY} - ${textLineEdgeAlign}), 27700),
		1,
		true,
		false,
		'National cycle network route';
EoSQL
edgeOriginY=$((${edgeOriginY} - ${edgeBuffer} - ${edgeSizeY}))

echo " -> Regional cycle network..."
psql -Ugrough-map grough-map -h 127.0.0.1 << EoSQL
	INSERT INTO
		edge
		(edge_name, edge_class_id, edge_access_id, edge_geom, edge_tunnel, edge_slip, edge_bridge, edge_roundabout, edge_oneway, edge_level)
	SELECT
		'',		-- Name
		10,		-- Class
		8,		-- Access
		(ST_Dump(ST_SetSRID(ST_Collect(ARRAY[
			ST_MakeLine(ST_Point(${edgeOriginX}, ${edgeOriginY}), ST_Point(${edgeOriginX} + ${edgeSizeHalf}, ${edgeOriginY})),
			ST_MakeLine(ST_Point(${edgeOriginX} + ${edgeSizeHalf}, ${edgeOriginY}), ST_Point(${edgeOriginX} + ${edgeSizeX}, ${edgeOriginY}))
		]), 27700))).geom,
		false,	-- Tunnel
		false,	-- Slip
		false,	-- Bridge
		false,	-- Roundabout
		false,	-- One way
		0;		-- Level
	INSERT INTO
		route
		(route_class_id, route_name, route_ref)
	SELECT
		2,
		'Cycle Superhighway',
		'999';
	INSERT INTO
		edge_route
		(relation_route_id, relation_edge_id)
	SELECT
		(SELECT route_id FROM route WHERE route_ref = '999' AND route_class_id=2),
		edge_id
	FROM
		edge
	WHERE
		edge_geom && ST_Point(${edgeOriginX} + ${edgeSizeHalf}, ${edgeOriginY});
		
	INSERT INTO
		legend_text
		(text_geom, text_size, text_bold, text_italic, text_value)
	SELECT
		ST_SetSRID(ST_Point(${edgeOriginX} + ${edgeSizeX} + ${edgeBuffer}, ${edgeOriginY} + ${edgeSizeY}), 27700),
		1,
		true,
		false,
		'Regional cycle network route';
	INSERT INTO
		legend_text
		(text_geom, text_size, text_bold, text_italic, text_value)
	SELECT
		ST_SetSRID(ST_Point(${edgeOriginX} + ${edgeSizeX} + ${edgeBuffer}, ${edgeOriginY} + ${edgeSizeY} - ${textLineSpace}), 27700),
		1,
		false,
		false,
		'National and regional cycle routes may show names instead of numbers.';
EoSQL
edgeOriginY=$((${edgeOriginY} - ${edgeBuffer} - ${edgeSizeYNamed}))

echo "--> Generating tile..."
gm-tile LGND

echo "--> Removing legend data..."
removeOldLegend

echo "--> Legend complete."
