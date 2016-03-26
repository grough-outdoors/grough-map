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

# Generate a relief image
print('Creating interpolated surface elevation file...')
#call( "gdalwarp -ts 2000 2000 -r cubicspline -overwrite -of HFA ../OS\ datasets/1\:50\,000\ elevation/ASCII/" + map_ref_idx + ".asc relief/__dem.img", shell=True)
print('Creating hillshade file...')
#call( "gdaldem hillshade -compute_edges -alt 30 relief/__dem.img relief/__aspect_grey.tif", shell=True )
print('Creating aspect file...')
#call( "gdaldem color-relief relief/__dem.img grough_relief.txt relief/__relief.tif", shell=True )
print('Colouring aspect file...')
#call( "gm convert relief/__aspect_grey.tif -recolor \"0.5 0.5 0.5, 0.5 0.5 0.5, 0.0 0.0 0.0\" relief/__aspect.tif", shell=True )
print('Merging relief files together (1)...')
#call( "convert -size 2000x2000 xc:white -colorspace RGB -alpha set -depth 8 -type TrueColor -compose over \( relief/__relief.tif -alpha set -channel A -evaluate set 20% \) -composite relief/_relief1.tif", shell=True )
print('Merging relief files together (2)...')
#call( "convert relief/_relief1.tif -colorspace RGB -alpha set -depth 8 -type TrueColor -compose Overlay \( relief/__aspect.tif -alpha set -channel A -evaluate set 80% \) -composite relief/_relief2.tif", shell=True )
print('Merging relief files together (3)...')
#call( "convert -size 2000x2000 xc:white \( relief/_relief2.tif -alpha set -channel A -evaluate set 50% \) -composite relief/Relief.tif", shell=True )
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

