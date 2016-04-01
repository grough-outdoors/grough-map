@contour_line_thickness_major:	2.5;
@contour_line_thickness_minor:	1.5;
@contour_line_colour:			'#FF9900';
@contour_line_blend:			'multiply';
@contour_line_opacity:			0.5;

.contour {
	line-width: @contour_line_thickness_minor;
	line-color: @contour_line_colour;
	line-opacity: @contour_line_opacity;
	line-comp-op: @contour_line_blend;
	
	[elevation_major=1] {
		line-width: @contour_line_thickness_major;
	}
}
