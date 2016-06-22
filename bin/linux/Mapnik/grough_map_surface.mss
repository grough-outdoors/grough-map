@surface_default_blend:					multiply;

@woodland_default_border_thickness:		0.0;
@woodland_default_fill_colour:			#CCFBD2;
@woodland_default_casing_colour:		black;

@foreshore_default_border_thickness:	2.0;
@foreshore_default_fill_colour:			#F1F3F4;
@foreshore_default_casing_colour:		#C8CFD6;
@foreshore_default_fill_blend:			src-over;

@beach_default_border_thickness:		2.0;
@beach_default_fill_colour:				#FFFCD7;
@beach_default_casing_colour:			#116899;
@beach_default_fill_blend:				src-over;

@river_default_border_thickness:		2.0;
@river_default_fill_colour:				#c0e0ef;
@river_default_casing_colour:			#116899;

@tidal_default_border_thickness:		2.0;
@tidal_default_fill_colour:				@river_default_fill_colour;
@tidal_default_casing_colour:			@river_default_casing_colour;

@landform_default_border_thickness:		0.0;
@landform_default_fill_colour:			#707070;
@landform_default_fill_opacity:			0.5;
@landform_default_casing_colour:		black;

@stream_default_thickness:				1.5;
@stream_default_colour:					@river_default_casing_colour;

@default_border_thickness:				4.0;
@default_fill_colour:					white;
@default_casing_colour:					#C0C0C0;
@default_dash_line:						4;
@default_dash_space:					8;

@airport_default_border_thickness:		@default_border_thickness;
@airport_default_fill_colour:			@default_fill_colour;
@airport_default_casing_colour:			@default_casing_colour;
@airport_default_dash_line:				@default_dash_line;
@airport_default_dash_space:			@default_dash_space;

@other_default_border_thickness:		@default_border_thickness;
@other_default_fill_colour:				@default_fill_colour;
@other_default_casing_colour:			@default_casing_colour;
@other_default_dash_line:				@default_dash_line;
@other_default_dash_space:				@default_dash_space;

.surface[class_name="Woodland"] {
	line-width: @woodland_default_border_thickness;
	line-color: @woodland_default_casing_colour;
	polygon-fill: @woodland_default_fill_colour;
	polygon-comp-op: @surface_default_blend;
}

.surface[class_name="Foreshore"] {
	line-width: @foreshore_default_border_thickness;
	line-color: @foreshore_default_casing_colour;
	polygon-fill: @foreshore_default_fill_colour;
	polygon-comp-op: @foreshore_default_fill_blend;
}

.surface[class_name="Sand beach"] {
	line-width: @beach_default_border_thickness;
	line-color: @beach_default_casing_colour;
	polygon-fill: @beach_default_fill_colour;
	polygon-comp-op: @beach_default_fill_blend;
}

.surface[class_name="Surface water"] {
	line-width: @river_default_border_thickness;
	line-color: @river_default_casing_colour;
	polygon-fill: @river_default_fill_colour;
}

.surface[class_name="Tidal water"] {
	line-width: @tidal_default_border_thickness;
	line-color: @tidal_default_casing_colour;
	polygon-fill: @tidal_default_fill_colour;
}

.surface[class_name="Landform"] {
	polygon-fill: @landform_default_fill_colour;
	polygon-opacity: @landform_default_fill_opacity;
	line-width: @landform_default_border_thickness;
	line-color: @landform_default_casing_colour;
}

.watercourse-line[class_draw_line=1] {
	line-width: @stream_default_thickness;
	line-color: @stream_default_colour;
}

/*
.surface[class_name="Taxiway"],
.surface[class_name="Runway"] {
	::casing {
		line-width: @airport_default_border_thickness;
		line-color: @airport_default_casing_colour;
		line-dasharray: @airport_default_dash_line, @airport_default_dash_space;
	}
	::fill {
		polygon-fill: @airport_default_fill_colour;
	}
}
*/

.surface[class_name="Activity area"],
.surface[class_name="Grass"],
.surface[class_name="Car park"] {
	line-width: @other_default_border_thickness;
	line-color: @other_default_casing_colour;
	line-dasharray: @other_default_dash_line, @other_default_dash_space;
}
