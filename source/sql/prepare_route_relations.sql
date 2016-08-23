DROP TABLE IF EXISTS _tmp_routes;

-- Clean the data and discard nonsense routes
CREATE TABLE _tmp_routes
AS SELECT
	route_class_id,
	ST_Multi(ST_CollectionExtract(ST_Collect(route_geom), 2)) AS route_geom,
	Sum(route_geom_length) / 1000 AS route_geom_length,
	route_name,
	route_ref
FROM
(
	SELECT
		network,
		CASE WHEN network = 'NCN' THEN 1
		     WHEN network = 'RCN' THEN 2
		     WHEN network = 'LCN' THEN 3
		     WHEN network = 'NWN' THEN 5
		     WHEN network = 'RWN' THEN 6
		     WHEN network = 'LWN' THEN 7
		     ELSE null
		END AS route_class_id,
		CASE WHEN network IS NOT NULL
		      AND route_ref IS NOT NULL 
		      AND network IN ('NCN', 'RCN')
		      AND upper(route_ref) ~ '^([0-9])+([A-Z]|)$'
		     THEN network || ' ' || upper(route_ref)WHEN route_name NOT SIMILAR TO '%([0-9])+%' -- No refernece IDs in the proper names
		      AND lower(route_name) NOT SIMILAR TO '%cycle network%' 				-- No silly long names with extraneous information
		      AND lower(route_name) NOT SIMILAR TO '%cycle route%'	
		      AND unaccent(route_name) SIMILAR TO '%[A-Z]%'					-- Must contain at least a cap
		      AND unaccent(route_name) ~ '([=A-Za-z=\-''\(\) ])+' 				-- No silly characters
		      AND unaccent(route_name) NOT SIMILAR TO '([A-Z])+'
		      AND lower(route_name) NOT SIMILAR TO '%(^| )(blue|yellow|purple|green|red|orange)($| )%'	-- No silly colour routes
		     THEN trim(regexp_replace(regexp_replace(route_name, '\([^\(]+\)$', '', 'g'), ' \- ([^-])+$', '', 'g'))::character varying	-- Strip anything after brackets
		     ELSE null
		END AS route_name,
		CASE WHEN network IN ('NCN', 'RCN')
		      AND upper(route_ref) ~ '^([0-9])+([A-Z]|)$'
		     THEN upper(route_ref)
		     ELSE null
		END AS route_ref,
		route_geom,
		ST_Length(route_geom) AS route_geom_length
	FROM
	(
		SELECT
			ST_Collect(way) AS route_geom,
			CASE WHEN ncn IN ('yes', 'y', 'true') THEN 'NCN'
			     WHEN rcn IN ('yes', 'y', 'true') THEN 'RCN'
			     WHEN lcn IN ('yes', 'y', 'true') THEN 'LCN'
			     ELSE upper(network)
			END AS network,
			route_name,
			CASE WHEN ncn IN ('yes', 'y', 'true') THEN ncn_ref
			     WHEN rcn IN ('yes', 'y', 'true') THEN rcn_ref
			     WHEN lcn IN ('yes', 'y', 'true') THEN lcn_ref
			     ELSE null
			END AS route_ref
		FROM
			_src_osm_line
		WHERE
			(
			  network IN ('nwn', 'rwn', 'lcn', 'ncn', 'rcn', 'lcn') 
			  OR ncn IN ('yes', 'y', 'true')
			  OR rcn IN ('yes', 'y', 'true')
			  OR lcn IN ('yes', 'y', 'true')
			)
		AND
			( state IS NULL OR state != 'proposed' )
		GROUP BY
			network,
			route_name,
			ncn,
			ncn_ref,
			rcn,
			rcn_ref,
			lcn,
			lcn_ref
	) SA
	WHERE
		network IS NOT NULL
	AND
		network IN ('NWN', 'RWN', 'LWN', 'NCN', 'RCN')	-- No local cycle routes for now
) SB
WHERE
	route_name IS NOT NULL
AND
	route_class_id IS NOT NULL
GROUP BY
	route_name, route_ref, route_class_id
ORDER BY
	route_name;

CREATE INDEX "Idx: _tmp_routes::route_geom"
	ON _tmp_routes
	USING gist
	(route_geom);
ALTER TABLE _tmp_routes CLUSTER ON "Idx: _tmp_routes::route_geom";

SELECT Populate_Geometry_Columns('_tmp_routes'::regclass);

TRUNCATE TABLE route;

-- Assign routes their own ID numbers
INSERT INTO
	route
	(route_class_id, route_name, route_ref)
SELECT
	route_class_id,
	route_name,
	route_ref
FROM
	_tmp_routes;

-- Split to segments for easier matching later
DROP TABLE IF EXISTS
	_tmp_route_segments;
	
CREATE TABLE
	_tmp_route_segments
AS SELECT 
	route_id,
	ST_MakeLine(sp,ep) AS route_geom
FROM
(
	SELECT
		route_id,
		ST_PointN(geom, generate_series(1, ST_NPoints(geom)-1)) as sp,
		ST_PointN(geom, generate_series(2, ST_NPoints(geom)  )) as ep
	FROM
	(
		SELECT 
			route_id,
			(ST_Dump(d.route_geom)).geom
		FROM 
			route r
		INNER JOIN
			_tmp_routes d
		ON
			r.route_name = d.route_name
		AND
			( r.route_ref = d.route_ref OR (r.route_ref IS NULL AND d.route_ref IS NULL) )
		AND
			r.route_class_id = d.route_class_id
	) linestrings
) segments;

CREATE INDEX "Idx: _tmp_route_segments::route_geom"
	ON _tmp_route_segments
	USING gist
	(route_geom);
ALTER TABLE _tmp_route_segments CLUSTER ON "Idx: _tmp_route_segments::route_geom";
