@zone_crow_line_pattern:			url("/vagrant/source/cartography/crow-line.png");
@zone_crow_line_blend:				plus;

@zone_crow_fill_color:				#8B1A1A;
@zone_crow_fill_blend:				multiply;
@zone_crow_fill_opacity:			0.05;

.zone {
	[class_name='Countryside and Rights of Way Access Land'] {
		/*
		polygon-pattern-file: @zone_crow_fill_pattern;
		polygon-pattern-alignment: @zone_crow_fill_alignment;
		polygon-pattern-opacity: @zone_crow_fill_opacity;
		polygon-pattern-comp-op: @zone_crow_fill_blend;
		*/
		
		polygon-fill: @zone_crow_fill_color;
		polygon-opacity: @zone_crow_fill_opacity;
		polygon-comp-op: @zone_crow_fill_blend;
	
		border/line-pattern-file: @zone_crow_line_pattern;
		border/line-pattern-comp-op: @zone_crow_line_blend;
	}
}
