@place_label_source:				[place_name];
@place_label_colour:				black;
@place_label_opacity:				1.0;
@place_label_blend:					src-over;
@place_label_placement_type:		simple;
@place_label_default_size:			70;
@place_label_typeface:				'Open Sans Regular';
@place_label_avoid_edges:			false;
@place_label_character_spacing:		2;
@place_label_minimum_padding:		50;
@place_label_halo_radius:			2;
@place_label_halo_colour:			white;

@place_label_default_size:			30;
@place_label_city_size:				70;
@place_label_town_size:				55;
@place_label_village_size:			43;
@place_label_suburb_size:			40;
@place_label_hamlet_size:			30;
@place_label_settlement_size:		25;
@place_label_hill_size:				50;
@place_label_mountain_size:			60;

@place_label_default_wrap_width:	1;
@place_label_city_wrap_width:		400;
@place_label_town_wrap_width:		100;
@place_label_village_wrap_width:	50;
@place_label_suburb_wrap_width:		50;
@place_label_hamlet_wrap_width:		1;
@place_label_settlement_wrap_width:	1;
@place_label_hill_wrap_width:		100;
@place_label_mountain_wrap_width:	100;

.place-label {
	text-name: @place_label_source;
	text-face-name: @place_label_typeface;
	text-fill: @place_label_colour;
	text-opacity: @place_label_opacity;
	text-size: @place_label_default_size;
	text-placement-type: @place_label_placement_type;
	text-wrap-width: @place_label_default_wrap_width;
	text-avoid-edges: @place_label_avoid_edges;
	text-character-spacing: @place_label_character_spacing;
	text-min-padding: @place_label_minimum_padding;
	text-halo-radius: @place_label_halo_radius;
	text-halo-fill: @place_label_halo_colour;
	
	[class_name='City'] {
		text-size: @place_label_city_size;
		text-wrap-width: @place_label_city_wrap_width;
	}
	[class_name='Town'] {
		text-size: @place_label_town_size;
		text-wrap-width: @place_label_town_wrap_width;
	}
	[class_name='Suburb'] {
		text-size: @place_label_suburb_size;
		text-wrap-width: @place_label_suburb_wrap_width;
	}
	[class_name='Village'] {
		text-size: @place_label_village_size;
		text-wrap-width: @place_label_village_wrap_width;
	}
	[class_name='Hamlet'] {
		text-size: @place_label_hamlet_size;
		text-wrap-width: @place_label_hamlet_wrap_width;
	}
	[class_name='Settlement'] {
		text-size: @place_label_settlement_size;
		text-wrap-width: @place_label_settlement_wrap_width;
	}
	[class_name='Hill'] {
		text-size: @place_label_hill_size;
		text-wrap-width: @place_label_hill_wrap_width;
	}
	[class_name='Mountain'] {
		text-size: @place_label_mountain_size;
		text-wrap-width: @place_label_mountain_wrap_width;
	}
	
	[place_direction >= 315][place_direction < 45] {
		/* Centre is to the north */
		text-placements: "S, SW, SE";
	}
	[place_direction >= 45][place_direction < 135] {
		/* Centre is to the east */
		text-placements: "W, NW, SW";
	}
	[place_direction >= 135][place_direction < 225] {
		/* Centre is to the south */
		text-placements: "N, NE, NW";
	}
	[place_direction >= 225][place_direction < 315] {
		/* Centre is to the west */
		text-placements: "E, SE, NE";
	}
}
