@route_marker_default_size:					20;
@route_marker_default_blend:				src-over;
@route_marker_default_opacity:				0.7;
@route_marker_default_multi:				each;
@route_marker_default_spacing:				150;
@route_marker_default_placement:			line;
@route_marker_default_overlap:				true;

@route_label_default_source:				[route_name];
@route_label_default_colour:				#707070;
@route_label_default_placement:				line;
@route_label_default_size:					40;
@route_label_default_offset_x:				0;
@route_label_default_offset_y:				-17;
@route_label_default_max_delta:				20;
@route_label_default_halo_radius:			3;
@route_label_default_halo_colour:			rgba(255, 255, 255, 0.6);
@route_label_default_distance:				2000;
@route_label_default_wrap_width:			0; /* Disabled */
@route_label_default_typeface:				'Open Sans Regular';
@route_label_default_avoid_edges:			false;
@route_label_default_minimum_padding:		0;

@route_marker_trail_prow_opacity:			1.0;

@route_label_ncn_colour:					@edge_a_road_fill_colour;
@route_label_nat_trail_colour:				darken(@edge_access_decorator_legalpath_colour, 10%);

@route_marker_ncn_file:						url("/vagrant/source/cartography/route-dot-ncn.png");
@route_marker_rcn_file:						url("/vagrant/source/cartography/route-dot-rcn.png");
@route_marker_trail_file:					url("/vagrant/source/cartography/route-dot-trail.png");
@route_marker_ncn_rcn_file:					url("/vagrant/source/cartography/route-dot-ncn-rcn.png");
@route_marker_ncn_trail_file:				url("/vagrant/source/cartography/route-dot-ncn-trail.png");
@route_marker_rcn_trail_file:				url("/vagrant/source/cartography/route-dot-rcn-trail.png");
@route_marker_ncn_rcn_trail_file:			url("/vagrant/source/cartography/route-dot-ncn-rcn-trail.png");

.route-markings {
	marker-height: @route_marker_default_size;
	marker-opacity: @route_marker_default_opacity;
	marker-comp-op: @route_marker_default_blend;
	marker-multi-policy: @route_marker_default_multi;
	marker-spacing: @route_marker_default_spacing;
	marker-placement: @route_marker_default_placement;
	marker-allow-overlap: @route_marker_default_overlap;
	
	[edge_access_name='Footpath'],
	[edge_access_name='Legal footpath'],
	[edge_access_name='Bridleway or cycle path'] {
		marker-opacity: @route_marker_trail_prow_opacity;
	}
	
	[class_name=~'.*National cycle network.*'] {
		marker-file: @route_marker_ncn_file;
	}
	
	[class_name=~'.*Regional cycle network.*'] {
		marker-file: @route_marker_rcn_file;
	}
	
	[class_name=~'.*National trail.*'],
	[class_name=~'.*Regional trail.*']	{
		marker-file: @route_marker_trail_file;
	}
	
	[class_name=~'.*National cycle network.*']
	[class_name=~'.*Regional cycle network.*']	{
		marker-file: @route_marker_ncn_rcn_file;
	}
	
	[class_name=~'.*National cycle network.*']
	[class_name=~'.*National trail.*'],
	[class_name=~'.*National cycle network.*']
	[class_name=~'.*Regional trail.*'],	{
		marker-file: @route_marker_ncn_trail_file;
	}
	
	[class_name=~'.*Regional cycle network.*'][class_name=~'.*National trail.*'],
	[class_name=~'.*Regional cycle network.*'][class_name=~'.*Regional trail.*'] {
		marker-file: @route_marker_rcn_trail_file;
	}
	
	[class_name=~'.*National cycle network.*']
	[class_name=~'.*Regional cycle network.*']
	[class_name=~'.*National trail.*']	{
		marker-file: @route_marker_ncn_rcn_trail_file;
	}
}

.route-label {
	[class_name='National cycle network'],
	[class_name='Regional cycle network'],
	[class_name='National trail'] {
		marker-height: 43;
		marker-opacity: 0.7;
		marker-max-error: 50;
		marker-comp-op: multiply;
		marker-allow-overlap: false;
		marker-placement: line;
		marker-multi-policy: each;
		marker-transform: translate(0, 35);
		[class_name='National cycle network'] { marker-spacing: 1800; }
		[class_name='Regional cycle network'] { marker-spacing: 1500; }
		[class_name='National trail'] { marker-spacing: 1300; }
	}
	
	[edge_max_length < 2000][edge_sum_length > 2000] {
		[class_name='National cycle network'] { marker-spacing: 1200; }
		[class_name='Regional cycle network'] { marker-spacing: 1000; }
		[class_name='National trail'] { marker-spacing: 800; }
	}
	
	[edge_max_length < 1250][edge_sum_length > 1500] {
		[class_name='National cycle network'] { marker-spacing: 700; }
		[class_name='Regional cycle network'] { marker-spacing: 600; }
		[class_name='National trail'] { marker-spacing: 500; }
	}
	
	[edge_max_length < 500][edge_sum_length > 1000] {
		[class_name='National cycle network'] { marker-spacing: 650; }
		[class_name='Regional cycle network'] { marker-spacing: 550; }
		[class_name='National trail'] { marker-spacing: 450; }
	}
	
	[edge_max_length < 0][edge_sum_length < 0] {
		[class_name='National cycle network'] { marker-spacing: 500; }
		[class_name='Regional cycle network'] { marker-spacing: 500; }
		[class_name='National trail'] { marker-spacing: 400; }
	}
}

.route-text {
	[class_name!='National cycle network']
	[class_name!='Regional cycle network'],
	[class_name='National cycle network'][route_ref=null],
	[class_name='Regional cycle network'][route_ref=null] {
		text-name: @route_label_default_source;
		text-face-name: @route_label_default_typeface;
		text-fill: @route_label_default_colour;
		text-size: @route_label_default_size;
		text-placement: @route_label_default_placement;
		text-dy: @route_label_default_size;
		text-max-char-angle-delta: @route_label_default_max_delta;
		text-halo-radius: @route_label_default_halo_radius;
		text-halo-fill: @route_label_default_halo_colour;
		text-min-distance: @route_label_default_distance;
		text-wrap-width: @route_label_default_wrap_width;
		text-avoid-edges: @route_label_default_avoid_edges;
		text-min-padding: @route_label_default_minimum_padding;

		[class_name='National cycle network'] {
			text-fill: @route_label_ncn_colour;
		}

		[class_name='National trail'] {
			text-fill: @route_label_nat_trail_colour;
		}
	}
}
