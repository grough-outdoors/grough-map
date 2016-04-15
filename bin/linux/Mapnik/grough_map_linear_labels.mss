@edge_label_default_source:					[edge_name_short];
@edge_label_default_source_long:			[edge_name];
@edge_label_default_colour:					#404040;
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
@edge_label_default_minimum_padding:		50;

@edge_label_motorway_colour:				darken(@edge_motorway_fill_colour, 20%);
@edge_label_trunk_colour:					darken(@edge_trunk_fill_colour, 20%);
@edge_label_a_road_colour:					darken(@edge_a_road_fill_colour, 20%);
@edge_label_b_road_colour:					darken(@edge_b_road_fill_colour, 20%);
@edge_label_other_road_colour:				@edge_label_default_colour;
@edge_label_path_colour:					#707070;

@edge_label_motorway_typeface:				'Open Sans Semibold';
@edge_label_trunk_typeface:					@edge_label_motorway_typeface;
@edge_label_a_road_typeface:				@edge_label_motorway_typeface;
@edge_label_b_road_typeface:				@edge_label_motorway_typeface;
@edge_label_other_road_typeface:			@edge_label_default_typeface;
@edge_label_path_typeface:					'Open Sans Regular';

@edge_label_motorway_halo_radius:			@edge_label_default_halo_radius;
@edge_label_trunk_halo_radius:				@edge_label_default_halo_radius;
@edge_label_a_road_halo_radius:				@edge_label_default_halo_radius;
@edge_label_b_road_halo_radius:				@edge_label_default_halo_radius;
@edge_label_other_road_halo_radius:			3;
@edge_label_path_halo_radius:				1;

@edge_label_motorway_size:					55;
@edge_label_trunk_size:						55;
@edge_label_a_road_size:					50;
@edge_label_b_road_size:					50;

@watercourse_label_default_source:			[watercourse_name];
@watercourse_label_default_colour:			@stream_default_colour;
@watercourse_label_default_placement:		line;
@watercourse_label_default_size:			50;
@watercourse_label_default_offset_x:		0;
@watercourse_label_default_offset_y_l:		@stream_default_thickness + @watercourse_label_default_size / 2;
@watercourse_label_default_offset_y_r:		0 - @stream_default_thickness - @watercourse_label_default_size / 2;
@watercourse_label_default_max_delta:		25;
@watercourse_label_default_halo_radius:		2;
@watercourse_label_default_halo_colour:		white;
@watercourse_label_default_distance:		2000;
@watercourse_label_default_wrap_width:		0; /* Disabled */
@watercourse_label_default_typeface:		'Open Sans Regular';
@watercourse_label_default_minimum_padding:	50;
@watercourse_label_default_avoid_edges:		false;

@watercourse_label_large_typeface:			'Exo Light';
@watercourse_label_large_halo_radius:		0;
@watercourse_label_large_offset_y:			0;
@watercourse_label_large_opacity:			0.7;

.edge-label {
	text-name: @edge_label_default_source;
	text-face-name: @edge_label_default_typeface;
	text-fill: @edge_label_other_road_colour;
	text-size: @edge_label_default_size;
	text-placement: @edge_label_default_placement;
	text-dy: @edge_label_default_size;
	text-max-char-angle-delta: @edge_label_default_max_delta;
	text-halo-radius: @edge_label_default_halo_radius;
	text-halo-fill: @edge_label_default_halo_colour;
	text-min-distance: @edge_label_default_distance;
	text-wrap-width: @edge_label_default_wrap_width;
	text-avoid-edges: @edge_label_default_avoid_edges;
	text-min-padding: @edge_label_default_minimum_padding;
	
	[edge_tunnel=1], 
	[edge_bridge=1] {
		text-name: @edge_label_default_source_long;
	}
	
	[class_name='Motorway'] {
		text-fill: @edge_label_motorway_colour;
		text-face-name: @edge_label_motorway_typeface;
		text-dy: @edge_motorway_width_dual + @edge_label_motorway_size / 2;
		text-halo-radius: @edge_label_motorway_halo_radius;
	}
	
	[class_name='Trunk road'] {
		text-fill: @edge_label_trunk_colour;
		text-face-name: @edge_label_trunk_typeface;
		text-dy: @edge_trunk_width_dual + @edge_label_trunk_size / 2;
		text-halo-radius: @edge_label_trunk_halo_radius;
	}
	
	[class_name='A road'] {
		text-fill: @edge_label_a_road_colour;
		text-face-name: @edge_label_a_road_typeface;
		text-dy: @edge_a_road_width_dual + @edge_label_a_road_size / 2;
		text-halo-radius: @edge_label_a_road_halo_radius;
	}
	
	[class_name='B road'] {
		text-fill: @edge_label_b_road_colour;
		text-face-name: @edge_label_b_road_typeface;
		text-dy: @edge_b_road_width_dual + @edge_label_b_road_size / 2;
		text-halo-radius: @edge_label_b_road_halo_radius;
	}
	
	[class_name='Right of way'],
	[class_name='Steps'],
	[class_name='Track'],
	[class_name='Path'] {
		text-fill: @edge_label_path_colour;
		text-face-name: @edge_label_path_typeface;
		text-halo-radius: @edge_label_path_halo_radius;
	}
}

.watercourse-label {
	text-name: @watercourse_label_default_source;
	text-face-name: @watercourse_label_default_typeface;
	text-fill: @watercourse_label_default_colour;
	text-size: @watercourse_label_default_size;
	text-placement: @watercourse_label_default_placement;
	text-max-char-angle-delta: @watercourse_label_default_max_delta;
	text-halo-radius: @watercourse_label_default_halo_radius;
	text-halo-fill: @watercourse_label_default_halo_colour;
	text-min-distance: @watercourse_label_default_distance;
	text-wrap-width: @watercourse_label_default_wrap_width;
	text-avoid-edges: @watercourse_label_default_avoid_edges;
	text-min-padding: @watercourse_label_default_minimum_padding;
	
	[class_name='Stream'] {
		text-dy: @watercourse_label_default_offset_y_r;
		[watercourse_label_side='r'] { text-dy: @watercourse_label_default_offset_y_r; }
		[watercourse_label_side='l'] { text-dy: @watercourse_label_default_offset_y_l; }
	}
	
	[class_name='River'],
	[class_name='Lake'],
	[class_name='Canal'],
	[class_name='Reservoir'],
	[class_name='Tidal river/estuary'] {
		[watercourse_width < @watercourse_label_default_size] {
			[watercourse_width < 5] { text-dy: 10 + @watercourse_label_default_size / 2; }
			[watercourse_width >= 5][watercourse_width < 15] { text-dy: 15 + @watercourse_label_default_size / 2; }
			[watercourse_width >= 15][watercourse_width < 25] { text-dy: 25 + @watercourse_label_default_size / 2; }
			[watercourse_width >= 25][watercourse_width < 35] { text-dy: 35 + @watercourse_label_default_size / 2; }
			[watercourse_width >= 35] { text-dy: @watercourse_label_default_size + @watercourse_label_default_size / 2; }
			[watercourse_label_side='r'] { 
				[watercourse_width < 5] { text-dy: -5 - @watercourse_label_default_size / 2; }
				[watercourse_width >= 5][watercourse_width < 15] { text-dy: -15 - @watercourse_label_default_size / 2; }
				[watercourse_width >= 15][watercourse_width < 25] { text-dy: -25 - @watercourse_label_default_size / 2; }
				[watercourse_width >= 25][watercourse_width < 35] { text-dy: -35 - @watercourse_label_default_size / 2; }
				[watercourse_width >= 35] { text-dy: 0 - @watercourse_label_default_size - @watercourse_label_default_size / 2; }
			}
		}
		[watercourse_width > @watercourse_label_default_size] {
			text-face-name: @watercourse_label_large_typeface;
			text-dy: @watercourse_label_large_offset_y;
			text-halo-radius: @watercourse_label_large_halo_radius;
			text-opacity: @watercourse_label_large_opacity;
			[watercourse_width < 60] { text-size: 50; }
			[watercourse_width >= 60][watercourse_width < 75] { text-size: 55; }
			[watercourse_width >= 75][watercourse_width < 100] { text-size: 60; }
			[watercourse_width >= 100][watercourse_width < 150] { text-size: 82; }
			[watercourse_width >= 150][watercourse_width < 200] { text-size: 125; }
			[watercourse_width >= 200] { text-size: 160; }
		}
	}
}
