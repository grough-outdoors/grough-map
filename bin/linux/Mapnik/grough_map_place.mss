@place_label_source:				[place_name];
@place_label_colour:				black;
@place_label_opacity:				1.0;
@place_label_blend:					src-over;
@place_label_placement_type:		simple;
@place_label_default_size:			70;
@place_label_typeface:				'Open Sans Regular';
@place_label_avoid_edges:			false;
@place_label_character_spacing:		2;
@place_label_minimum_padding:		20;
@place_label_halo_radius:			4;
@place_label_halo_colour:			rgba(255, 255, 255, 0.6);
@place_label_default_margin:		30;
@place_label_position_tolerance:	400;

@place_label_waterbody_colour:		@stream_default_colour;

@place_label_city_transform:		uppercase;
@place_label_town_transform:		uppercase;
@place_label_village_transform:		none;
@place_label_suburb_transform:		none;
@place_label_hamlet_transform:		none;
@place_label_settlement_transform:	none;
@place_label_hill_transform:		none;
@place_label_mountain_transform:	none;
@place_label_waterbody_transform:	none;

@place_label_city_typeface:			'Open Sans Bold';
@place_label_town_typeface:			'Open Sans Bold';
@place_label_village_typeface:		'Open Sans Semibold';
@place_label_suburb_typeface:		@place_label_typeface;
@place_label_hamlet_typeface:		@place_label_typeface;
@place_label_settlement_typeface:	@place_label_typeface;
@place_label_hill_typeface:			@place_label_typeface;
@place_label_mountain_typeface:		'Open Sans Semibold';
@place_label_waterbody_typeface:	@place_label_typeface;

@place_label_default_size:			45;
@place_label_city_size:				90;
@place_label_town_size:				70;
@place_label_village_size:			55;
@place_label_suburb_size:			45;
@place_label_hamlet_size:			40;
@place_label_settlement_size:		40;
@place_label_hill_size:				40;
@place_label_mountain_size:			55;
@place_label_waterbody_size:		40;

@place_label_default_wrap_width:	1;
@place_label_city_wrap_width:		400;
@place_label_town_wrap_width:		100;
@place_label_village_wrap_width:	50;
@place_label_suburb_wrap_width:		50;
@place_label_hamlet_wrap_width:		1;
@place_label_settlement_wrap_width:	1;
@place_label_hill_wrap_width:		100;
@place_label_mountain_wrap_width:	100;
@place_label_waterbody_wrap_width:	50;

.place-label {
	text-name: @place_label_source;
	text-face-name: @place_label_typeface;
	text-fill: @place_label_colour;
	text-opacity: @place_label_opacity;
	text-size: @place_label_default_size;
	text-placement: interior;
	text-min-distance: @place_label_default_margin;
	/* text-placement-type: @place_label_placement_type; */
	text-wrap-width: @place_label_default_wrap_width;
	text-avoid-edges: @place_label_avoid_edges;
	text-character-spacing: @place_label_character_spacing;
	text-min-padding: @place_label_minimum_padding;
	text-halo-radius: @place_label_halo_radius;
	text-halo-fill: @place_label_halo_colour;
	text-label-position-tolerance: @place_label_position_tolerance;
	
	[class_name='City'] {
		text-size: @place_label_city_size;
		text-face-name: @place_label_city_typeface;
		text-wrap-width: @place_label_city_wrap_width;
		text-transform: @place_label_city_transform;
	}
	[class_name='Town'] {
		text-size: @place_label_town_size;
		text-face-name: @place_label_town_typeface;
		text-wrap-width: @place_label_town_wrap_width;
		text-transform: @place_label_town_transform;
	}
	[class_name='Suburb'] {
		text-size: @place_label_suburb_size;
		text-face-name: @place_label_suburb_typeface;
		text-wrap-width: @place_label_suburb_wrap_width;
		text-transform: @place_label_suburb_transform;
	}
	[class_name='Village'] {
		text-size: @place_label_village_size;
		text-face-name: @place_label_village_typeface;
		text-wrap-width: @place_label_village_wrap_width;
		text-transform: @place_label_village_transform;
	}
	[class_name='Hamlet'] {
		text-size: @place_label_hamlet_size;
		text-face-name: @place_label_hamlet_typeface;
		text-wrap-width: @place_label_hamlet_wrap_width;
		text-transform: @place_label_hamlet_transform;
	}
	[class_name='Settlement'] {
		text-size: @place_label_settlement_size;
		text-face-name: @place_label_settlement_typeface;
		text-wrap-width: @place_label_settlement_wrap_width;
		text-transform: @place_label_settlement_transform;
	}
	[class_name='Hill'] {
		text-size: @place_label_hill_size;
		text-face-name: @place_label_hill_typeface;
		text-wrap-width: @place_label_hill_wrap_width;
		text-transform: @place_label_hill_transform;
	}
	[class_name='Mountain'] {
		text-size: @place_label_mountain_size;
		text-face-name: @place_label_mountain_typeface;
		text-wrap-width: @place_label_mountain_wrap_width;
		text-transform: @place_label_mountain_transform;
	}
	[class_name='Small waterbody'] {
		text-size: @place_label_waterbody_size;
		text-face-name: @place_label_waterbody_typeface;
		text-wrap-width: @place_label_waterbody_wrap_width;
		text-transform: @place_label_waterbody_transform;
		text-fill: @place_label_waterbody_colour;
	}
	
	/*
	[place_direction >= 315][place_direction < 45] {
		text-placements: "S, SW, SE";
	}
	[place_direction >= 45][place_direction < 135] {
		text-placements: "W, NW, SW";
	}
	[place_direction >= 135][place_direction < 225] {
		text-placements: "N, NE, NW";
	}
	[place_direction >= 225][place_direction < 315] {
		text-placements: "E, SE, NE";
	}
	*/
}
