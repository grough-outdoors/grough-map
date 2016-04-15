#!/usr/bin/env python

from __future__ import print_function
from subprocess import call
from mapnik import FontEngine as font, register_fonts;
import mapnik
import psycopg2
import sys

# Convert MML to XML
print('Creating XML file...')
call( "carto grough_map.mml > grough_map.xml", shell=True )
stylesheet = 'grough_map.xml'

# Custom fonts
print('Registering typefaces...')
register_fonts('/vagrant/source/typefaces/')
for face in font.face_names(): print('...'+face)

# Connect to the database
#pg_conn_string = "host='localhost' dbname='grough' user='luke' password='<snip>'"
pg_conn_string = "host='localhost' dbname='grough-map' user='grough-map'"
print('Connecting to PG database...')
pg_conn = psycopg2.connect( pg_conn_string )
pg_cursor = pg_conn.cursor()
print('Connected to database.')

# Fetch command line argument
map_ref_idx = str(sys.argv[1]).strip().upper()
map_target = 'output/' + map_ref_idx.lower() + '.png'

map_major_grid_idx = map_ref_idx[0:2]
map_minor_grid_idx = map_ref_idx

print('Target grid square is ', map_ref_idx, '...')
print('Target major grid is ', map_major_grid_idx, '...')
print('Target file is ', map_target, '...')

# Query the grid square in the fishnet
pg_cursor.execute("""\
		SELECT
			round( ST_XMin( tile_geom ) ) AS ll_x,
			round( ST_YMin( tile_geom ) ) AS ll_y,
			round( ST_XMax( tile_geom ) ) AS ur_x,
			round( ST_YMax( tile_geom ) ) AS ur_y
		FROM
			grid
		WHERE
			tile_name = %s
		LIMIT
			1;
	""",
	[ map_ref_idx ]
)

pg_grid_records = pg_cursor.fetchone()
map_ll_x = pg_grid_records[0]
map_ll_y = pg_grid_records[1]
map_ur_x = pg_grid_records[2]
map_ur_y = pg_grid_records[3]

print('Lower-left corner is  (', map_ll_x, ', ', map_ll_y, ')')
print('Upper-right corner is (', map_ur_x, ', ', map_ur_y, ')')

# Set constant values
print( map_major_grid_idx, file=open('constants/major_grid_idx.cnf', 'w'), end='' )
print( map_minor_grid_idx, file=open('constants/minor_grid_idx.cnf', 'w'), end='' )
print( str(map_ll_x) + ',' + str(map_ll_y) + ',' + str(map_ur_x) + ',' + str(map_ur_y), file=open('constants/extent_spatial.cnf', 'w'), end='' )
print( str(map_ll_x) + ' ' + str(map_ll_y) + ',' + str(map_ur_x) + ' ' + str(map_ur_y), file=open('constants/extent_sql.cnf', 'w'), end='' )
print( str(27700), file=open('constants/target_srid.cnf', 'w'), end='' )

print('Creating SQL table for label areas')
bufferSize = 0
distanceRoads = 30.0
distanceWatercourses = 100.0
pg_cursor.execute("DROP VIEW IF EXISTS map_render_place;")
pg_cursor.execute("DROP TABLE IF EXISTS _tmp_label_zone;")
pg_conn.commit()
pg_cursor.execute("""\
	CREATE TABLE _tmp_label_zone AS SELECT
		ST_MakeValid(label_zone)::geometry(Polygon, 27700) AS label_zone
	FROM (
		SELECT
			(ST_Dump(ST_Difference(
				g.tile_geom,
				( 
					SELECT ST_Union(
						ST_Buffer(
							buffer_geom, 
							buffer_distance, 
							'endcap=square join=bevel'
						)
				    ) AS buffer_geom 
					FROM (
						SELECT
							edge_geom AS buffer_geom,
							""" + str(distanceRoads) + """ AS buffer_distance
						FROM
							edge e 
						WHERE e.edge_geom && ST_SetSRID('BOX(""" + str(map_ll_x - bufferSize) + ' ' + str(map_ll_y - bufferSize) + ',' + str(map_ur_x + bufferSize) + ' ' + str(map_ur_y + bufferSize) + """)'::box2d, 27700) 
						UNION SELECT
							watercourse_geom AS buffer_geom,
							""" + str(distanceWatercourses) + """ AS buffer_distance
						FROM
							watercourse w 
						WHERE w.watercourse_geom && ST_SetSRID('BOX(""" + str(map_ll_x - bufferSize) + ' ' + str(map_ll_y - bufferSize) + ',' + str(map_ur_x + bufferSize) + ' ' + str(map_ur_y + bufferSize) + """)'::box2d, 27700)
					) SA
				)
			))).geom AS label_zone
		FROM
			grid g
		WHERE
			g.tile_name = '""" + map_ref_idx + """'
	) SA
	WHERE
		ST_XMax(label_zone) - ST_XMin(label_zone) > 50.0
	AND ST_YMax(label_zone) - ST_YMin(label_zone) > 50.0;
	"""
)
pg_conn.commit()

print('Creating SQL view for gridlines')
pg_cursor.execute("""\
	CREATE OR REPLACE VIEW "map_render_grid_lines" AS
		SELECT  
			( ( ST_XMin( tile_geom )::integer % 100000 ) / 10000 )::text || ( subgrid_east / 1000 ) AS grid_id_east,
			( ( ST_YMin( tile_geom )::integer % 100000 ) / 10000 )::text || ( subgrid_north / 1000 ) AS grid_id_north,
			ST_SetSRID( 
				ST_MakeBox2D(
					ST_Point( ST_XMin( tile_geom ) + subgrid_east       , ST_YMin( tile_geom ) + subgrid_north ),
					ST_Point( ST_XMin( tile_geom ) + subgrid_east + 1000, ST_YMin( tile_geom ) + subgrid_north + 1000 )
				),
			27700 ) AS grid_box
		FROM 
			grid
		LEFT JOIN 
			generate_series(0,9000,1000) AS subgrid_east ON true 
		LEFT JOIN 
			generate_series(0,9000,1000) AS subgrid_north ON true
		WHERE 
			tile_name = '""" + map_ref_idx + """';
	"""
)
pg_conn.commit()

print('Creating SQL view for grid labels')
pg_cursor.execute("""\
	CREATE OR REPLACE VIEW "map_render_grid_labels" AS
		SELECT  
			( ( ( ST_XMin( tile_geom )::integer + subgrid_step ) % 100000 ) / 10000 )::text || ( ( subgrid_step / 1000 ) % 10 ) AS grid_id_text,
			'e' AS grid_id_dir,
			ST_SetSRID( 
				ST_MakePoint( ST_XMin( tile_geom ) + subgrid_step, ST_YMin( tile_geom ) + 3300 ),
			27700 ) AS grid_text_point
		FROM 
			grid
		LEFT JOIN 
			generate_series(0,10000,1000) AS subgrid_step ON true 
		WHERE 
			tile_name = '""" + map_ref_idx + """'
		UNION SELECT  
			( ( ( ST_YMin( tile_geom )::integer + subgrid_step ) % 100000 ) / 10000 )::text || ( ( subgrid_step / 1000 ) % 10 ) AS grid_id_text,
			'n' AS grid_id_dir,
			ST_SetSRID( 
				ST_MakePoint( ST_XMin( tile_geom ) + 3300, ST_YMin( tile_geom ) +  + subgrid_step ),
			27700 ) AS grid_text_point
		FROM 
			grid
		LEFT JOIN 
			generate_series(0,10000,1000) AS subgrid_step ON true 
		WHERE 
			tile_name = '""" + map_ref_idx + """';
	"""
)
pg_conn.commit()

print('Creating SQL view for zones')
pg_cursor.execute("""\
	CREATE OR REPLACE VIEW "map_render_zone\" AS 
	SELECT * 
	FROM zone_extended
	WHERE zone_geom && ST_SetSRID('BOX(""" + str(map_ll_x) + ' ' + str(map_ll_y) + ',' + str(map_ur_x) + ' ' + str(map_ur_y) + """)'::box2d, """ + str(27700) + """);
	"""
)
pg_conn.commit()

print('Creating SQL view for surface features below zones')
pg_cursor.execute("""\
	CREATE OR REPLACE VIEW "map_render_surface_below_zones\" AS 
	SELECT * 
	FROM surface_extended
	WHERE class_below_zones = true AND surface_geom && ST_SetSRID('BOX(""" + str(map_ll_x) + ' ' + str(map_ll_y) + ',' + str(map_ur_x) + ' ' + str(map_ur_y) + """)'::box2d, """ + str(27700) + """);
	"""
)
pg_conn.commit()

print('Creating SQL view for surface features above zones')
pg_cursor.execute("""\
	CREATE OR REPLACE VIEW "map_render_surface_above_zones\" AS 
	SELECT * 
	FROM surface_extended
	WHERE class_below_zones = false AND surface_geom && ST_SetSRID('BOX(""" + str(map_ll_x) + ' ' + str(map_ll_y) + ',' + str(map_ur_x) + ' ' + str(map_ur_y) + """)'::box2d, """ + str(27700) + """);
	"""
)
pg_conn.commit()

print('Creating SQL view for place features')
pg_cursor.execute("""\
	CREATE OR REPLACE VIEW "map_render_place\" AS 
	SELECT 
		p.place_id,
		p.place_name,
		p.place_class_id,
		CASE WHEN l.place_id IS NULL THEN ST_Multi(p.place_geom)
			 ELSE ST_Multi(l.place_geom)
		END::geometry(MultiPolygon, 27700) as place_geom,
		degrees(ST_Azimuth(l.place_nearest, p.place_centre_geom)) AS place_direction,
		p.class_name
	FROM 
		place_extended p
	LEFT JOIN
	(
		SELECT
			first(place_id) AS place_id,
			first(place_geom) AS place_geom,
			first(place_nearest) AS place_nearest
		FROM
		(
			SELECT
				place_id,
				place_geom,
				place_nearest
			FROM
			(
				SELECT
					place_id,
					place_centre_geom,
					class_text_size,
					class_wrap_width,
					place_name,
					CASE WHEN c.class_prefer_no_expansion = true AND ST_XMax(place_geom) - ST_XMin(place_geom) > class_text_size * longest_word(place_name) * 0.6  THEN place_geom
					     ELSE ST_Intersection(ST_Buffer(ST_ClosestPoint(ST_Intersection(place_geom, z.label_zone), place_centre_geom), class_text_size * longest_word(place_name) * 0.80, 'quad_segs=2'), z.label_zone) 
					END AS place_geom,
					ST_ClosestPoint(ST_Intersection(place_geom, z.label_zone), place_centre_geom) AS place_nearest
				FROM
					place p
				LEFT JOIN
					place_classes c
				ON
					c.class_id = p.place_class_id
				LEFT JOIN
					_tmp_label_zone z
				ON
					z.label_zone && p.place_geom
				WHERE
					p.place_centre_geom && ST_SetSRID('BOX(""" + str(map_ll_x) + ' ' + str(map_ll_y) + ',' + str(map_ur_x) + ' ' + str(map_ur_y) + """)'::box2d, """ + str(27700) + """)
			) SA
			WHERE
				ST_XMax(place_geom) - ST_XMin(place_geom) > class_text_size * longest_word(place_name) * 0.7
			ORDER BY
				-- Preferred placement? One which has lots of space...
				CASE WHEN ST_XMax(place_geom) - ST_XMin(place_geom) > class_text_size * longest_word(place_name) * 2.0 THEN true
				     ELSE false
				END DESC,
				ST_Distance(place_geom, place_centre_geom) ASC
		) SB
		GROUP BY
			place_id
	) l
	ON
		p.place_id = l.place_id
	WHERE 
		p.place_centre_geom && ST_SetSRID('BOX(""" + str(map_ll_x) + ' ' + str(map_ll_y) + ',' + str(map_ur_x) + ' ' + str(map_ur_y) + """)'::box2d, """ + str(27700) + """)
	AND	
		p.class_label = true;
	"""
)
pg_conn.commit()

print('Creating SQL view for watercourse features')
pg_cursor.execute("""\
	CREATE OR REPLACE VIEW "map_render_watercourse\" AS 
	SELECT 
		w.*
	FROM 
		watercourse_extended w
	WHERE 
		watercourse_geom && ST_SetSRID('BOX(""" + str(map_ll_x) + ' ' + str(map_ll_y) + ',' + str(map_ur_x) + ' ' + str(map_ur_y) + """)'::box2d, """ + str(27700) + """);
	"""
)
pg_conn.commit()

print('Creating SQL views for linear features')
pg_cursor.execute("""\
	CREATE OR REPLACE VIEW "map_render_feature_line_subsurface\" AS 
	SELECT 
		f.*
	FROM 
		feature_linear_extended f
	WHERE 
		feature_geom && ST_SetSRID('BOX(""" + str(map_ll_x) + ' ' + str(map_ll_y) + ',' + str(map_ur_x) + ' ' + str(map_ur_y) + """)'::box2d, """ + str(27700) + """)
	AND	
		class_subsurface = true;
	"""
)
pg_conn.commit()
pg_cursor.execute("""\
	CREATE OR REPLACE VIEW "map_render_feature_line_surface\" AS 
	SELECT 
		f.*
	FROM 
		feature_linear_extended f
	WHERE 
		feature_geom && ST_SetSRID('BOX(""" + str(map_ll_x) + ' ' + str(map_ll_y) + ',' + str(map_ur_x) + ' ' + str(map_ur_y) + """)'::box2d, """ + str(27700) + """)
	AND	
		class_surface = true;
	"""
)
pg_conn.commit()
pg_cursor.execute("""\
	CREATE OR REPLACE VIEW "map_render_feature_line_overhead\" AS 
	SELECT 
		f.*
	FROM 
		feature_linear_extended f
	WHERE 
		feature_geom && ST_SetSRID('BOX(""" + str(map_ll_x) + ' ' + str(map_ll_y) + ',' + str(map_ur_x) + ' ' + str(map_ur_y) + """)'::box2d, """ + str(27700) + """)
	AND	
		class_overhead = true;
	"""
)
pg_conn.commit()

print('Creating SQL views for point features')
pg_cursor.execute("""\
	CREATE OR REPLACE VIEW "map_render_feature_point_subsurface\" AS 
	SELECT 
		f.*
	FROM 
		feature_point_extended f
	WHERE 
		feature_geom && ST_SetSRID('BOX(""" + str(map_ll_x) + ' ' + str(map_ll_y) + ',' + str(map_ur_x) + ' ' + str(map_ur_y) + """)'::box2d, """ + str(27700) + """)
	AND	
		class_subsurface = true;
	"""
)
pg_conn.commit()
pg_cursor.execute("""\
	CREATE OR REPLACE VIEW "map_render_feature_point_surface\" AS 
	SELECT 
		f.*
	FROM 
		feature_point_extended f
	WHERE 
		feature_geom && ST_SetSRID('BOX(""" + str(map_ll_x) + ' ' + str(map_ll_y) + ',' + str(map_ur_x) + ' ' + str(map_ur_y) + """)'::box2d, """ + str(27700) + """)
	AND	
		class_surface = true;
	"""
)
pg_conn.commit()
pg_cursor.execute("""\
	CREATE OR REPLACE VIEW "map_render_feature_point_overhead\" AS 
	SELECT 
		f.*
	FROM 
		feature_point_extended f
	WHERE 
		feature_geom && ST_SetSRID('BOX(""" + str(map_ll_x) + ' ' + str(map_ll_y) + ',' + str(map_ur_x) + ' ' + str(map_ur_y) + """)'::box2d, """ + str(27700) + """)
	AND	
		class_overhead = true;
	"""
)
pg_conn.commit()

print('Creating SQL view for watercourse feature labels')
pg_cursor.execute("""\
	CREATE OR REPLACE VIEW "map_render_watercourse_labels\" AS 
	SELECT 
		w.watercourse_id,
		w.watercourse_class_id,
		w.watercourse_width,
		CASE WHEN ST_GeometryType(SB.watercourse_geom_trim) = 'ST_MultiLineString'
		     THEN SB.watercourse_geom_trim
			 ELSE w.watercourse_geom
		END as watercourse_geom,
		w.watercourse_name,
		w.class_name,
		w.class_draw_order,
		w.class_draw_line,
		SB.watercourse_label_side 
	FROM 
		watercourse_label w
	LEFT JOIN
	(
		SELECT
			watercourse_id,
			CASE WHEN Sum(watercourse_label_direction) > 0 THEN 'r'
				 WHEN Sum(watercourse_label_direction) < 0 THEN 'l'
				 ELSE 'b'
			END AS watercourse_label_side,
			ST_Multi(ST_Difference(watercourse_geom, ST_Union(watercourse_edge_near))) AS watercourse_geom_trim
		FROM
		(
			SELECT
				watercourse_id,
				CASE WHEN 
					degrees(ST_Azimuth(
						ST_Line_Interpolate_Point(w.watercourse_split_geom, 0.5),
						ST_Line_Interpolate_Point(w.watercourse_split_geom, least(1.0, 0.5 + 100.0 / ST_Length(watercourse_split_geom)))
					)) >
					degrees(ST_Azimuth(
						ST_Line_Interpolate_Point(w.watercourse_split_geom, 0.5),
						ST_ClosestPoint(e.edge_geom, ST_Line_Interpolate_Point(w.watercourse_split_geom, 0.5))
					)) 
				THEN 1
				ELSE -1
				END AS watercourse_label_direction,
				watercourse_geom,
				ST_Buffer(e.edge_geom, 25.0) AS watercourse_edge_near
			FROM
				( SELECT *, (ST_Dump(watercourse_geom)).geom AS watercourse_split_geom FROM watercourse ) w, edge e
			WHERE
				watercourse_geom && ST_SetSRID('BOX(""" + str(map_ll_x) + ' ' + str(map_ll_y) + ',' + str(map_ur_x) + ' ' + str(map_ur_y) + """)'::box2d, """ + str(27700) + """)
			AND
				w.watercourse_geom && e.edge_geom
			AND
				ST_DWithin(w.watercourse_geom, e.edge_geom, 50.0)
		) SA
		GROUP BY
			watercourse_id, watercourse_geom
	) SB
	ON
		SB.watercourse_id = w.watercourse_id
	WHERE 
		watercourse_geom && ST_SetSRID('BOX(""" + str(map_ll_x) + ' ' + str(map_ll_y) + ',' + str(map_ur_x) + ' ' + str(map_ur_y) + """)'::box2d, """ + str(27700) + """);
	"""
)
pg_conn.commit()

print('Creating SQL view for elevation features')
pg_cursor.execute("""\
	CREATE OR REPLACE VIEW "map_render_elevation\" AS 
	SELECT 
		*,
		CASE WHEN elevation_level::integer % 50 = 0 THEN true ELSE false END AS elevation_major
	FROM elevation
	WHERE elevation_geom && ST_SetSRID('BOX(""" + str(map_ll_x) + ' ' + str(map_ll_y) + ',' + str(map_ur_x) + ' ' + str(map_ur_y) + """)'::box2d, """ + str(27700) + """);
	"""
)
pg_conn.commit()

print('Creating SQL view for feature labels')
pg_cursor.execute("""\
	CREATE OR REPLACE VIEW "map_render_feature_labels\" AS 
	SELECT
		CASE WHEN ST_Area(feature_geom) > class_radius * class_radius * 4
			 THEN class_plural_name
			 ELSE class_name
		END AS feature_name,
		ST_Multi(ST_Difference(feature_geom, ST_Buffer(feature_avoid, 40.0)))::geometry(MultiPolygon, 27700) AS feature_geom
	FROM
	(
		SELECT
			class_name,
			class_plural_name,
			class_radius,
			class_label_rank,
			ST_Collect(edge_geom) AS feature_avoid,
			(ST_Dump(ST_Union(ST_Buffer(feature_geom, class_radius)))).geom::geometry(Polygon, 27700) AS feature_geom
		FROM
		(
			SELECT 
				*
			FROM 
				feature_label
			LEFT JOIN
				edge e
			ON
				e.edge_geom && feature_geom
			AND
				ST_DWithin(feature_geom, e.edge_geom, class_radius)
			WHERE
				feature_geom && ST_MakeBox2D(ST_Point(""" + str(map_ll_x) + """, """ + str(map_ll_y) + """), ST_Point(""" + str(map_ur_x) + """, """ + str(map_ur_y) + """))
		) f
		GROUP BY
			class_name, class_plural_name, class_radius, class_label_rank
	) SB
	ORDER BY
		class_label_rank DESC;
	"""
)
pg_conn.commit()

print('Creating SQL view for edge labels')
pg_cursor.execute("""\
	CREATE OR REPLACE VIEW "map_render_edge_labels\" AS 
	SELECT
		l.*,
		SA.edge_geom
	FROM
		edge_label l
	INNER JOIN
	(
		SELECT 
			a.edge_id,
			CASE WHEN a.edge_class_id IN (1,2,3,4) THEN a.edge_geom
				 WHEN ST_GeometryType(ST_Multi(ST_Difference(a.edge_geom, ST_Union(ST_Buffer(b.edge_geom, 40.0, 'endcap=square join=mitre mitre_limit=20.0'))))) != 'ST_MultiLineString' THEN NULL
				 ELSE ST_Multi(ST_Difference(a.edge_geom, ST_Union(ST_Buffer(b.edge_geom, 40.0, 'endcap=square join=mitre mitre_limit=20.0')))) 
			END AS edge_geom
		FROM 
			edge a, edge b
		WHERE
			a.edge_geom && ST_MakeBox2D(ST_Point(""" + str(map_ll_x) + """, """ + str(map_ll_y) + """), ST_Point(""" + str(map_ur_x) + """, """ + str(map_ur_y) + """))
		AND
			a.edge_name IS NOT NULL
		AND
			( a.edge_name != b.edge_name OR a.edge_class_id != b.edge_class_id OR b.edge_name IS NULL )
		AND
			a.edge_geom && b.edge_geom
		AND
			a.edge_id != b.edge_id
		AND
			ST_DWithin(a.edge_geom, b.edge_geom, 20.0)
		GROUP BY
			a.edge_id, a.edge_geom
	) SA
	ON
		l.edge_id = SA.edge_id;
	"""
)
pg_conn.commit()

for level in xrange(-4, 5):
    print('Creating SQL view for edges at level ', level)
    pg_cursor.execute("""\
        CREATE OR REPLACE VIEW "map_render_edge_l""" + str(level) + """\" AS 
        SELECT * 
        FROM edge_extended
        WHERE edge_geom && ST_SetSRID('BOX(""" + str(map_ll_x) + ' ' + str(map_ll_y) + ',' + str(map_ur_x) + ' ' + str(map_ur_y) + """)'::box2d, """ + str(27700) + """)
        AND edge_level = """ + str(level) + """;
        """
    )
    pg_conn.commit()
    print('Creating SQL view for buildings at level ', level)
    pg_cursor.execute("""\
        CREATE OR REPLACE VIEW "map_render_building_l""" + str(level) + """\" AS 
        SELECT * 
        FROM buildings
        WHERE building_geom && ST_SetSRID('BOX(""" + str(map_ll_x) + ' ' + str(map_ll_y) + ',' + str(map_ur_x) + ' ' + str(map_ur_y) + """)'::box2d, """ + str(27700) + """)
        AND building_layer = """ + str(level) + """;
        """
    )
    pg_conn.commit()


# TODO: Test for the grid file existing	
# Generate a relief image
print('Creating hillshade file...')
call( "gdaldem hillshade -compute_edges -alt 30 /vagrant/source/terrain-composite/grid/" + map_ref_idx + ".img relief/__aspect_grey.tif", shell=True )
print('Creating aspect file...')
call( "gdaldem color-relief /vagrant/source/terrain-composite/grid/" + map_ref_idx + ".img grough_relief.txt relief/__relief.tif", shell=True )
print('Colouring aspect file...')
call( "convert relief/__aspect_grey.tif -recolor \"0.5 0.5 0.5, 0.5 0.5 0.5, 0.0 0.0 0.0\" -resize 500x500  relief/__aspect.tif", shell=True )
print('Merging relief files together (1)...')
call( "convert -size 500x500 xc:white -colorspace RGB -alpha set -depth 8 -type TrueColor -compose over \( relief/__relief.tif -alpha set -channel A -evaluate set 20% \) -composite relief/_relief1.tif", shell=True )
print('Merging relief files together (2)...')
call( "convert relief/_relief1.tif -colorspace RGB -alpha set -depth 8 -type TrueColor -compose Overlay \( relief/__aspect.tif -alpha set -channel A -evaluate set 80% \) -composite relief/_relief2.tif", shell=True )
print('Merging relief files together (3)...')
call( "convert -size 500x500 xc:white \( relief/_relief2.tif -alpha set -channel A -evaluate set 50% \) -composite -depth 8 -layers flatten relief/Relief.tif", shell=True )
print('Adding georeference information...')
call( "gdal_translate -ot Byte -a_srs EPSG:27700 -a_ullr `gdalinfo relief/__aspect_grey.tif | awk '/(Upper Left)|(Lower Right)/' | awk '{gsub(/,|\)|\(/,\" \");print $3 \" \" $4}' | sed ':a;N;$!ba;s/\\n/ /g'` relief/Relief.tif relief/ReliefGeo.tif", shell=True )
print('Finished creating hillshade overlay')

print('Creating map raster...')
# Set map dimensions in pixels
m = mapnik.Map(8000, 8000)

# Load the map definition
mapnik.load_map(m, stylesheet)

# Render to file
m.zoom_to_box(mapnik.Box2d( map_ll_x, map_ll_y, map_ur_x, map_ur_y ))
mapnik.render_to_file(m, map_target)

print('Completed map generation')

# Done... pub.
sys.exit(0)

