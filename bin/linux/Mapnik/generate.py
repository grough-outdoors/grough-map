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

print('Creating SQL view for surface features')
pg_cursor.execute("""\
	CREATE OR REPLACE VIEW "map_render_surface\" AS 
	SELECT * 
	FROM surface_extended
	WHERE surface_geom && ST_SetSRID('BOX(""" + str(map_ll_x) + ' ' + str(map_ll_y) + ',' + str(map_ur_x) + ' ' + str(map_ur_y) + """)'::box2d, """ + str(27700) + """);
	"""
)
pg_conn.commit()

print('Creating SQL view for watercourse features')
pg_cursor.execute("""\
	CREATE OR REPLACE VIEW "map_render_watercourse\" AS 
	SELECT * 
	FROM watercourse_extended
	WHERE watercourse_geom && ST_SetSRID('BOX(""" + str(map_ll_x) + ' ' + str(map_ll_y) + ',' + str(map_ur_x) + ' ' + str(map_ur_y) + """)'::box2d, """ + str(27700) + """);
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

print('Creating SQL view for edge labels')
pg_cursor.execute("""\
	CREATE OR REPLACE VIEW "map_render_edge_labels\" AS 
	SELECT * 
	FROM edge_label
	WHERE edge_geom && ST_SetSRID('BOX(""" + str(map_ll_x) + ' ' + str(map_ll_y) + ',' + str(map_ur_x) + ' ' + str(map_ur_y) + """)'::box2d, """ + str(27700) + """)
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
call( "convert relief/__aspect_grey.tif -recolor \"0.5 0.5 0.5, 0.5 0.5 0.5, 0.0 0.0 0.0\" relief/__aspect.tif", shell=True )
print('Merging relief files together (1)...')
call( "convert -size 2000x2000 xc:white -colorspace RGB -alpha set -depth 8 -type TrueColor -compose over \( relief/__relief.tif -alpha set -channel A -evaluate set 20% \) -composite relief/_relief1.tif", shell=True )
print('Merging relief files together (2)...')
call( "convert relief/_relief1.tif -colorspace RGB -alpha set -depth 8 -type TrueColor -compose Overlay \( relief/__aspect.tif -alpha set -channel A -evaluate set 80% \) -composite relief/_relief2.tif", shell=True )
print('Merging relief files together (3)...')
call( "convert -size 2000x2000 xc:white \( relief/_relief2.tif -alpha set -channel A -evaluate set 50% \) -composite -depth 8 -layers flatten relief/Relief.tif", shell=True )
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

