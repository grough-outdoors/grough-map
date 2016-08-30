(function (window, document) {
'use strict';

document.addEventListener( "DOMContentLoaded", initMap, false );

var map, mapLayer, mapAttribution, mapBounds, mapProjection, mapExtent;

function initMap() {
	proj4.defs('EPSG:27700', '+proj=tmerc +lat_0=49 +lon_0=-2 +k=0.9996012717 +x_0=400000 +y_0=-100000 +ellps=airy +datum=OSGB36 +units=m +no_defs');
	
	mapExtent = [0.0, 0.0, 700000, 1400000];
	
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
                origin: [0, 0],
                resolutions: [10000.0, 1000.0, 100.0]
            }),
            tileUrlFunction: function(coordinate) {
				return '/something/coordinate_' + coordinate + '.jpg';
            }
        })
    });
	
	map = new ol.Map({
		target: 'map',
		layers: [mapLayer],
		view: new ol.View({
			projection: mapProjection,
			center: [500000, 500000],
			zoom: 1
		})
	});
}

})(window, document);
