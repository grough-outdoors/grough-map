@woodland_default_border_thickness:		0.0;
@woodland_default_fill_colour:			'#AEE8BE';
@woodland_default_casing_colour:		'black';

@foreshore_default_border_thickness:	2.0;
@foreshore_default_fill_colour:			'#FFFCD7';
@foreshore_default_casing_colour:		'#116899';

@river_default_border_thickness:		2.0;
@river_default_fill_colour:				'#c0e0ef';
@river_default_casing_colour:			'#116899';

@tidal_default_border_thickness:		2.0;
@tidal_default_fill_colour:				'#c0e0ef';
@tidal_default_casing_colour:			'#116899';

@landform_default_border_thickness:		0.0;
@landform_default_fill_colour:			'black';
@landform_default_casing_colour:		'black';

.surface[class_name="Woodland"] {
	line-width: @woodland_default_border_thickness;
	line-color: @woodland_default_casing_colour;
	polygon-fill: @woodland_default_fill_colour;
}

.surface[class_name="Foreshore"] {
	line-width: @foreshore_default_border_thickness;
	line-color: @foreshore_default_casing_colour;
	polygon-fill: @foreshore_default_fill_colour;
}

.surface[class_name="River"] {
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
	line-width: @landform_default_border_thickness;
	line-color: @landform_default_casing_colour;
}
