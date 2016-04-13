@feature_wall_thickness:			2.0;
@feature_wall_colour:				#555;
@feature_wall_blend:				src-over;
@feature_wall_opacity:				0.7;

@feature_hedge_thickness:			@feature_wall_thickness;
@feature_hedge_colour:				@feature_wall_colour;
@feature_hedge_blend:				@feature_wall_blend;
@feature_hedge_opacity:				@feature_wall_opacity;

@feature_fence_thickness:			@feature_wall_thickness;
@feature_fence_colour:				@feature_wall_colour;
@feature_fence_blend:				@feature_wall_blend;
@feature_fence_opacity:				@feature_wall_opacity;

@feature_cable_thickness:			2.0;
@feature_cable_colour:				red;
@feature_cable_blend:				multiply;
@feature_cable_opacity:				0.5;
@feature_cable_dash_line:			10;
@feature_cable_dash_space:			20;

@feature_pylon_shape:				ellipse;
@feature_pylon_size:				6.0;
@feature_pylon_colour:				@feature_cable_colour;
@feature_pylon_blend:				src-over;
@feature_pylon_opacity:				1.0;

@feature_label_default_size:		30;
@feature_label_default_wrap_width:	1;
@feature_label_source:				[feature_name];
@feature_label_colour:				black;
@feature_label_opacity:				1.0;
@feature_label_placement_type:		simple;
@feature_label_placement:			interior;
@feature_label_typeface:			'Open Sans Regular';
@feature_label_avoid_edges:			false;
@feature_label_character_spacing:	2;
@feature_label_minimum_padding:		75;
@feature_label_displacement:		50;
@feature_label_halo_radius:			2;
@feature_label_halo_colour:			white;
@feature_label_alignment:			left;

.feature-label {
	text-name: @feature_label_source;
	text-face-name: @feature_label_typeface;
	text-fill: @feature_label_colour;
	text-opacity: @feature_label_opacity;
	text-size: @feature_label_default_size;
	text-placement-type: @feature_label_placement_type;
	text-placement: @feature_label_placement;
	text-wrap-width: @feature_label_default_wrap_width;
	text-avoid-edges: @feature_label_avoid_edges;
	text-character-spacing: @feature_label_character_spacing;
	text-min-padding: @feature_label_minimum_padding;
	text-label-position-tolerance: @feature_label_displacement;
	text-halo-radius: @feature_label_halo_radius;
	text-halo-fill: @feature_label_halo_colour;
	text-horizontal-alignment: @feature_label_alignment;
}

.feature-line {
	[class_name='Wall'] {
		line-width: @feature_wall_thickness;
		line-color: @feature_wall_colour;
		line-opacity: @feature_wall_opacity;
		line-comp-op: @feature_wall_blend;
	}
	
	[class_name='Hedge'] {
		line-width: @feature_hedge_thickness;
		line-color: @feature_hedge_colour;
		line-opacity: @feature_hedge_opacity;
		line-comp-op: @feature_hedge_blend;
	}
	
	[class_name='Fence'] {
		line-width: @feature_fence_thickness;
		line-color: @feature_fence_colour;
		line-opacity: @feature_fence_opacity;
		line-comp-op: @feature_fence_blend;
	}
	
	[class_name='Overhead cables'] {
		line-width: @feature_cable_thickness;
		line-color: @feature_cable_colour;
		line-opacity: @feature_cable_opacity;
		line-comp-op: @feature_cable_blend;
		line-dasharray: @feature_cable_dash_line, @feature_cable_dash_space;
	}
}

.feature-point {
	[class_name='Pylon'] {
		marker-type: @feature_pylon_shape;
		marker-width: @feature_pylon_size;
		marker-fill: @feature_pylon_colour;
		marker-opacity: @feature_pylon_opacity;
		marker-comp-op: @feature_pylon_blend;
	}
}