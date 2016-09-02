(function (window, document) {
'use strict';

document.addEventListener( "DOMContentLoaded", initAll, false );

var mapSuperScale   = 1.5;
var mapExtent  		= [0.0, 0.0, 700000, 1400000];
var mapTilePrefix   = '../product/pyramid/';

var map
var mapLayer;
var mapAttribution;
var mapBounds;
var mapProjection;
var mapResolutions;
var mapTileSize;
var mapOffsets;
var mapControlBeta;

function initAll() {
	initMap();
	initSearch();
}

function initMap() {
	proj4.defs('EPSG:27700', '+proj=tmerc +lat_0=49 +lon_0=-2 +k=0.9996012717 +x_0=400000 +y_0=-100000 +ellps=airy +datum=OSGB36 +units=m +no_defs');
	
	mapTileSize = 1024 / mapSuperScale;
	mapResolutions = [160000 / mapTileSize];

	mapOffsets = [1];
	for (var i = 1; i <= 7; i++) {
		mapOffsets[i] = mapOffsets[i - 1] + 40 * Math.pow(Math.pow(2, i - 1), 2);
		mapResolutions[i] = mapResolutions[i - 1] / 2;
	}
	
	mapProjection = new ol.proj.Projection({
		code: 'EPSG:27700',
		extent: mapExtent,
		units: 'm'
	});
	ol.proj.addProjection(mapProjection);
	
	mapAttribution = new ol.Attribution({
		html: '&copy; grough Ltd, OpenStreetMap contributors, Ordnance Survey. ' +
			  '<a href="http://map.grough.co.uk/sources/">Legal information and sources</a>.'
	});
	
    mapLayer = new ol.layer.Tile({
        source: new ol.source.TileImage({
            crossOrigin: null,
            extent: mapExtent,
            projection: mapProjection,
			attributions: [mapAttribution],
			tilePixelRatio: mapSuperScale,
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
					return mapTilePrefix + '/LOD' + level + '/' + id + '.jpg';
				}
			})(mapOffsets)
        })
    });
	
	mapControlBeta = document.createElement('div');
	mapControlBeta.innerHTML = '<div class="logo"><img src="gm-logo.png" alt="grough map"/></div><div class="text">1:25,000 BETA</div>';
	mapControlBeta.className = 'ol-unselectable ol-control gm-version';
	
	map = new ol.Map({
		target: 'map',
		layers: [mapLayer],
		controls: ol.control
			.defaults({attribution: false})
			.extend([
				new ol.control.Control({
					className: 'gm-version',
					element: mapControlBeta
				}),
				new ol.control.Attribution({
					collapsible: false
				})
			]),
		view: new ol.View({
			projection: mapProjection,
			center: [425218,564812],
			zoom: 10
		})
	});
}

function zoomToExtent(extent) {
	var mapView = map.getView();
	mapView.fit(extent, map.getSize());
}

window.map = {
	zoomToExtent: zoomToExtent
};

})(window, document);
