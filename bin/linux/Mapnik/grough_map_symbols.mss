@feature_symbol_default_size:		35;
@feature_symbol_default_blend:		src-over;
@feature_symbol_default_opacity:	1.0;
@feature_symbol_default_placement:	largest;
@feature_symbol_default_multi:		each;

@feature_symbol_shelter_file:		url("/vagrant/source/cartography/shelter.png");
@feature_symbol_survey_point_file:	url("/vagrant/source/cartography/survey-point.png");
@feature_symbol_lighthouse_file:	url("/vagrant/source/cartography/lighthouse.png");
@feature_symbol_monument_file:		url("/vagrant/source/cartography/monument.png");
@feature_symbol_flagpole_file:		url("/vagrant/source/cartography/flagpole.png");
@feature_symbol_picnic_site_file:	url("/vagrant/source/cartography/picnic-site.png");

.feature-symbol {
	marker-width: @feature_symbol_default_size;
	marker-height: @feature_symbol_default_size;
	marker-opacity: @feature_symbol_default_opacity;
	marker-comp-op: @feature_symbol_default_blend;
	marker-multi-policy: @feature_symbol_default_multi;
	
	[class_name='Survey point'] {
		marker-file: @feature_symbol_survey_point_file;
	}
	
	[class_name='Shelter'] {
		marker-file: @feature_symbol_shelter_file;
	}
	
	[class_name='Lighthouse'] {
		marker-file: @feature_symbol_lighthouse_file;
	}
	
	[class_name='Monument'] {
		marker-file: @feature_symbol_monument_file;
	}
	
	[class_name='Flagpole'] {
		marker-file: @feature_symbol_flagpole_file;
	}
	
	[class_name='Picnic site'] {
		marker-file: @feature_symbol_picnic_site_file;
	}
}
