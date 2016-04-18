@grid_line_thickness:				2.5;
@grid_line_colour:					#00CCFF;
@grid_line_blend:					multiply;
@grid_line_opacity:					0.35;

@grid_label_source:					[grid_id_text];
@grid_label_colour:					@grid_line_colour;
@grid_label_opacity:				0.35;
@grid_label_blend:					multiply;
@grid_label_placement:				point;
@grid_label_size:					70;
@grid_label_wrap_width:				0; /* Disabled */
@grid_label_typeface:				'Open Sans Bold';
@grid_label_avoid_edges:			false;
@grid_label_allow_overlap:			true;
@grid_label_character_spacing:		12;

.grid {
	line-width: @grid_line_thickness;
	line-color: @grid_line_colour;
	line-opacity: @grid_line_opacity;
	line-comp-op: @grid_line_blend;
}

.grid-label {
	text-name: @grid_label_source;
	text-face-name: @grid_label_typeface;
	text-fill: @grid_label_colour;
	text-opacity: @grid_label_opacity;
	text-size: @grid_label_size;
	text-placement: @grid_label_placement;
	text-wrap-width: @grid_label_wrap_width;
	text-avoid-edges: @grid_label_avoid_edges;
	text-allow-overlap: @grid_label_allow_overlap;
	text-character-spacing: @grid_label_character_spacing;
	[grid_id_dir='e'] {
		text-orientation: 0;
	}
	[grid_id_dir='n'] {
		text-orientation: 270;
	}
}
