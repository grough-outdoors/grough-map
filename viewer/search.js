(function (window, document) {
'use strict';

var searchElement;
var searchInput;

function initSearch() {
	var body = document.getElementsByTagName('body')[0];
	
	searchElement = document.createElement('div');
	searchElement.id = 'search';
	searchElement.className = 'search';
	
	searchInput = document.createElement('input');
	searchInput.placeholder = 'Grid reference...';
	searchInput.addEventListener('keydown', submitSearch);
	searchElement.appendChild(searchInput);
	
	body.appendChild(searchElement);
}

function submitSearch(e) {
	if (e.keyCode !== 13) return;
	
	var searchTerm = searchInput.value;
	searchInput.value = '';
	
	var searchExtent = resolveGridReference(searchTerm);
	
	map.zoomToExtent(searchExtent);
}

function resolveGridReference(gridString) {
	var gridChars = 'ABCDEFGHJKLMNOPQRSTUVWXYZ';
	
	gridString = gridString.toUpperCase().trim().replace(/\s/g, '');
	if (gridString.length < 4 ||
		gridString.length > 12 ||
	    gridString.length % 2 !== 0) {
		return false;
	}
	
	var gridLetters = gridString.substr(0, 2);
	var gridEast = gridString.substr(2, (gridString.length - 2)/2);
	var gridNorth = gridString.substr(gridString.length / 2 + 1, (gridString.length - 2)/2);
	
	var gridLetter1 = gridChars.indexOf(gridLetters.substr(0, 1));
	var gridLetter2 = gridChars.indexOf(gridLetters.substr(1, 1));
	
	var indexBaseE = parseInt(((gridLetter1 - 2) % 5) * 5 + (gridLetter2 % 5), 10) * 100000;
	var indexBaseN = parseInt((19 - Math.floor(gridLetter1 / 5) * 5) - Math.floor(gridLetter2 / 5), 10)  * 100000;
	var indexResolution = Math.pow(10, 5 - (gridString.length - 2) / 2);
	
	indexBaseE += parseInt(gridEast + '00000'.substr(0, 5 - gridEast.length), 10);
	indexBaseN += parseInt(gridNorth + '00000'.substr(0, 5 - gridNorth.length), 10);
	
	var indexCenterE = indexBaseE + indexResolution / 2;
	var indexCenterN = indexBaseN + indexResolution / 2;
	var indexViewResolution = Math.max(100, indexResolution / 2);
	
	return ol.extent.boundingExtent([
		[indexCenterE - indexViewResolution, indexCenterN - indexViewResolution],
		[indexCenterE + indexViewResolution, indexCenterN + indexViewResolution]
	]);
}

window.initSearch = initSearch;

})(window, document);
