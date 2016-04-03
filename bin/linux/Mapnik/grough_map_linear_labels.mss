@edge_label_default_source:					[edge_name_short];
@edge_label_default_source_long:			[edge_name];
@edge_label_default_colour:					black;
@edge_label_default_placement:				line;
@edge_label_default_size:					40;
@edge_label_default_offset_x:				0;
@edge_label_default_offset_y:				@edge_track_width + @edge_label_default_size / 2;
@edge_label_default_max_delta:				15;
@edge_label_default_halo_radius:			2;
@edge_label_default_halo_colour:			white;
@edge_label_default_distance:				2000;
@edge_label_default_wrap_width:				0; /* Disabled */
@edge_label_default_typeface:				'Open Sans Regular';
@edge_label_default_avoid_edges:			true;

@edge_label_motorway_colour:				darken(@edge_motorway_fill_colour, 20%);
@edge_label_trunk_colour:					darken(@edge_trunk_fill_colour, 40%);
@edge_label_a_road_colour:					darken(@edge_a_road_fill_colour, 20%);
@edge_label_b_road_colour:					darken(@edge_b_road_fill_colour, 40%);

@edge_label_motorway_size:					50;
@edge_label_trunk_size:						50;
@edge_label_a_road_size:					45;
@edge_label_b_road_size:					45;

@watercourse_label_default_source:			[watercourse_name];
@watercourse_label_default_colour:			@stream_default_colour;
@watercourse_label_default_placement:		line;
@watercourse_label_default_size:			40;
@watercourse_label_default_offset_x:		0;
@watercourse_label_default_offset_y:		@stream_default_thickness + @watercourse_label_default_size / 2;
@watercourse_label_default_max_delta:		15;
@watercourse_label_default_halo_radius:		2;
@watercourse_label_default_halo_colour:		white;
@watercourse_label_default_distance:		2000;
@watercourse_label_default_wrap_width:		0; /* Disabled */
@watercourse_label_default_typeface:		'Open Sans Regular';
@watercourse_label_default_avoid_edges:		true;

@watercourse_label_large_typeface:			'Exo Bold';
@watercourse_label_large_halo_radius:		0;
@watercourse_label_large_offset_y:			0;
@watercourse_label_large_opacity:			0.4;

.edge-label {
	text-name: @edge_label_default_source;
	text-face-name: @edge_label_default_typeface;
	text-fill: @edge_label_default_colour;
	text-size: @edge_label_default_size;
	text-placement: @edge_label_default_placement;
	text-dy: @edge_label_default_size;
	text-max-char-angle-delta: @edge_label_default_max_delta;
	text-halo-radius: @edge_label_default_halo_radius;
	text-halo-fill: @edge_label_default_halo_colour;
	text-min-distance: @edge_label_default_distance;
	text-wrap-width: @edge_label_default_wrap_width;
	text-avoid-edges: @edge_label_default_avoid_edges;
	
	[edge_tunnel=1], 
	[edge_bridge=1] {
		text-name: @edge_label_default_source_long;
	}
	
	[class_name='Motorway'] {
		text-fill: @edge_label_motorway_colour;
		text-dy: @edge_motorway_width_dual + @edge_label_motorway_size / 2;
	}
	
	[class_name='Trunk road'] {
		text-fill: @edge_label_trunk_colour;
		text-dy: @edge_trunk_width_dual + @edge_label_trunk_size / 2;
	}
	
	[class_name='A road'] {
		text-fill: @edge_label_a_road_colour;
		text-dy: @edge_a_road_width_dual + @edge_label_a_road_size / 2;
	}
	
	[class_name='B road'] {
		text-fill: @edge_label_b_road_colour;
		text-dy: @edge_b_road_width_dual + @edge_label_b_road_size / 2;
	}
}

.watercourse-label {
	text-name: @watercourse_label_default_source;
	text-face-name: @watercourse_label_default_typeface;
	text-fill: @watercourse_label_default_colour;
	text-size: @watercourse_label_default_size;
	text-placement: @watercourse_label_default_placement;
	text-dy: @watercourse_label_default_size;
	text-max-char-angle-delta: @watercourse_label_default_max_delta;
	text-halo-radius: @watercourse_label_default_halo_radius;
	text-halo-fill: @watercourse_label_default_halo_colour;
	text-min-distance: @watercourse_label_default_distance;
	text-wrap-width: @watercourse_label_default_wrap_width;
	text-avoid-edges: @watercourse_label_default_avoid_edges;
	text-label-position-tolerance: 400.0;
	
	[class_name='River'],
	[class_name='Lake'],
	[class_name='Canal'],
	[class_name='Reservoir'],
	[class_name='Tidal river/estuary'] {
		[watercourse_width < @watercourse_label_default_size] {
			[watercourse_width < 5] { text-dy: 5 + @watercourse_label_default_size / 2; }
			[watercourse_width >= 5][watercourse_width < 15] { text-dy: 15 + @watercourse_label_default_size / 2; }
			[watercourse_width >= 15][watercourse_width < 25] { text-dy: 25 + @watercourse_label_default_size / 2; }
			[watercourse_width >= 25][watercourse_width < 35] { text-dy: 35 + @watercourse_label_default_size / 2; }
			[watercourse_width >= 35] { text-dy: @watercourse_label_default_size + @watercourse_label_default_size / 2; }
		}
		[watercourse_width > @watercourse_label_default_size] {
			text-face-name: @watercourse_label_large_typeface;
			text-dy: @watercourse_label_large_offset_y;
			text-halo-radius: @watercourse_label_large_halo_radius;
			text-opacity: @watercourse_label_large_opacity;
			[watercourse_width < 50] { text-size: 40; }
			[watercourse_width >= 50][watercourse_width < 75] { text-size: 45; }
			[watercourse_width >= 75][watercourse_width < 100] { text-size: 70; }
			[watercourse_width >= 100][watercourse_width < 150] { text-size: 95; }
			[watercourse_width >= 150][watercourse_width < 200] { text-size: 145; }
			[watercourse_width >= 200] { text-size: 195; }
		}
	}
}
