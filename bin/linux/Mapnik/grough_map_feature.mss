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