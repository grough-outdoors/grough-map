@contour_line_thickness_major:	2.5;
@contour_line_thickness_minor:	1.5;
@contour_line_colour:			rgb(255, 153, 0);
@contour_line_blend:			multiply;
@contour_line_opacity:			0.5;

@contour_label_default_source:				[elevation_level];
@contour_label_rotation:					[elevation_text_rotate];
@contour_label_default_colour:				rgba(255, 153, 0, 0.5);
@contour_label_default_opacity:				1.0;
@contour_label_default_placement:			point;
@contour_label_default_upright:				left;
@contour_label_default_size:				23;
@contour_label_default_max_delta:			15;
@contour_label_default_halo_radius:			5;
@contour_label_default_halo_colour:			white;
@contour_label_default_distance:			50;
@contour_label_default_wrap_width:			0; /* Disabled */
@contour_label_default_typeface:			'Open Sans Regular';
@contour_label_default_avoid_edges:			true;
@contour_label_default_minimum_padding:		50;

.contour {
	line-width: @contour_line_thickness_minor;
	line-color: @contour_line_colour;
	line-opacity: @contour_line_opacity;
	line-comp-op: @contour_line_blend;
	
	[elevation_major=1] {
		line-width: @contour_line_thickness_major;
	}
}

.contour-label {
	text-name: @contour_label_default_source;
	text-orientation: @contour_label_rotation;
	text-opacity: @contour_label_default_opacity;
	text-face-name: @contour_label_default_typeface;
	text-fill: @contour_label_default_colour;
	text-size: @contour_label_default_size;
	text-placement: @contour_label_default_placement;
	text-max-char-angle-delta: @contour_label_default_max_delta;
	text-min-distance: @contour_label_default_distance;
	text-wrap-width: @contour_label_default_wrap_width;
	text-avoid-edges: @contour_label_default_avoid_edges;
	text-min-padding: @contour_label_default_minimum_padding;
	text-halo-radius: @contour_label_default_halo_radius;
	text-halo-fill: @contour_label_default_halo_colour;
}
