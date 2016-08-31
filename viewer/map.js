(function (window, document) {
'use strict';

document.addEventListener( "DOMContentLoaded", initMap, false );

var map, mapLayer, mapAttribution, mapBounds, mapProjection, mapExtent, mapResolutions, mapTileSize, mapOffsets;

function initMap() {
	proj4.defs('EPSG:27700', '+proj=tmerc +lat_0=49 +lon_0=-2 +k=0.9996012717 +x_0=400000 +y_0=-100000 +ellps=airy +datum=OSGB36 +units=m +no_defs');
	
	mapExtent = [0.0, 0.0, 700000, 1400000];
	mapTileSize = 1024;
	mapResolutions = [
		160000 / mapTileSize, 	// LOD0
		80000 / mapTileSize, 	// LOD1
		40000 / mapTileSize, 	// LOD2
		20000 / mapTileSize, 	// LOD3
		10000 / mapTileSize, 	// LOD4
		5000 / mapTileSize, 	// LOD5
		2500 / mapTileSize,		// LOD6
		1250 / mapTileSize		// LOD7
	];
	
	mapOffsets = [1];
	for (var i = 1; i <= 7; i++) {
		mapOffsets[i] = mapOffsets[i - 1] + 40 * Math.pow(Math.pow(2, i - 1), 2);
		console.log('Offset ' + i + ' is ' + mapOffsets[i]);
	}
	
	mapProjection = new ol.proj.Projection({
		code: 'EPSG:27700',
		extent: mapExtent,
		units: 'm'
	});
	ol.proj.addProjection(mapProjection);
	
	mapAttribution = new ol.Attribution({
		html: '&copy; grough Ltd, OpenStreetMap contributors, Ordnance Survey. ' +
			  '<a href="http://map.grough.co.uk/sources/">Legal</a>.'
	});
	
    mapLayer = new ol.layer.Tile({
        source: new ol.source.TileImage({
            crossOrigin: null,
            extent: mapExtent,
            projection: mapProjection,
			attributions: [mapAttribution],
            tileGrid: new ol.tilegrid.TileGrid({
                extent: mapExtent,
				tileSize: [mapTileSize, mapTileSize],
                origin: [0, 0],
                resolutions: mapResolutions
            }),
            tileUrlFunction: (function (mapOffsets) { 
				return function(coordinate) {
					var level = coordinate[0];
					var x = coordinate[1];
					var y = coordinate[2];
					var gridSize = [
						5 * Math.pow(2, level),
						8 * Math.pow(2, level)
					];
					var id = mapOffsets[level] + x * gridSize[1] + y;
					console.log('Tile URL Data: ', mapOffsets[level], coordinate, x, y, gridSize, id);
					return '../product/pyramid/LOD' + level + '/' + id + '.jpg';
				}
			})(mapOffsets)
        })
    });
	
	map = new ol.Map({
		target: 'map',
		layers: [mapLayer],
		view: new ol.View({
			projection: mapProjection,
			center: [425218,564812],
			//center: [500, 500],
			zoom: 10
		})
	});
}

})(window, document);
