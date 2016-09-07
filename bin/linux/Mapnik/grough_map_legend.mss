@legend_label_source:						[text_value];
@legend_label_colour:						black;
@legend_label_opacity:						1.0;
@legend_label_blend:						src-over;
@legend_label_typeface:						'Open Sans Light';
@legend_label_avoid_edges:					false;
@legend_label_character_spacing:			1;
@legend_label_minimum_padding:				0;
@legend_label_halo_radius:					0;
@legend_label_default_margin:				30;
@legend_label_position_tolerance:			0;
@legend_label_default_wrap_width:			700;
@legend_label_default_size:					42;

.legend-text {
	text-name: @legend_label_source;
	text-face-name: @legend_label_typeface;
	text-fill: @legend_label_colour;
	text-opacity: @legend_label_opacity;
	text-size: @legend_label_default_size;
	text-min-distance: @legend_label_default_margin;
	text-wrap-width: @legend_label_default_wrap_width;
	text-character-spacing: @legend_label_character_spacing;
	text-min-padding: @legend_label_minimum_padding;
	text-label-position-tolerance: @legend_label_position_tolerance;
	
	text-placement: point;
	text-placement-type: simple;
	text-placements: SW;
	text-avoid-edges: false;
	text-dx: 0;
	text-dy: -5;
	text-align: left;
	text-horizontal-alignment: right;
	text-allow-overlap: true;
	
	[text_bold=1] {
		text-face-name: 'Open Sans Regular';
	}
	
	[text_italic=1] {
		text-face-name: 'Open Sans Light Italic';
	}
	
	[text_bold=1][text_italic=1] {
		text-face-name: 'Open Sans Italic';
	}
}
