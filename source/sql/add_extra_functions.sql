-- Create a function that always returns the first non-NULL item
CREATE OR REPLACE FUNCTION public.first_agg ( anyelement, anyelement )
RETURNS anyelement LANGUAGE SQL IMMUTABLE STRICT AS $$
        SELECT $1;
$$;
 
-- And then wrap an aggregate around it
CREATE AGGREGATE public.FIRST (
        sfunc    = public.first_agg,
        basetype = anyelement,
        stype    = anyelement
);
 
-- Create a function that always returns the last non-NULL item
CREATE OR REPLACE FUNCTION public.last_agg ( anyelement, anyelement )
RETURNS anyelement LANGUAGE SQL IMMUTABLE STRICT AS $$
        SELECT $2;
$$;
 
-- And then wrap an aggregate around it
CREATE AGGREGATE public.LAST (
        sfunc    = public.last_agg,
        basetype = anyelement,
        stype    = anyelement
);

CREATE OR REPLACE FUNCTION array_sort (ANYARRAY)
RETURNS ANYARRAY LANGUAGE SQL
AS $$
SELECT ARRAY(SELECT unnest($1) ORDER BY 1)
$$;

-- Credit for this function:
-- http://www.spatialdbadvisor.com/postgis_tips_tricks/92/filtering-rings-in-polygon-postgis
CREATE OR REPLACE FUNCTION filter_rings(geometry,FLOAT) RETURNS geometry AS
$$ SELECT ST_BuildArea(ST_Collect(d.built_geom)) AS filtered_geom
     FROM (SELECT ST_BuildArea(ST_Collect(c.geom)) AS built_geom
             FROM (SELECT b.geom
                     FROM (SELECT (ST_DumpRings(ST_GeometryN(ST_Multi($1),/*ST_Multi converts any Single Polygons to MultiPolygons */
                                                            generate_series(1,ST_NumGeometries(ST_Multi($1)) )
                                                            ))).*
                           ) b
                    WHERE b.path[1] = 0 OR
                         (b.path[1] > 0 AND ST_Area(b.geom) > $2)
                   ) c
           ) d
$$
LANGUAGE 'sql' IMMUTABLE;

CREATE OR REPLACE FUNCTION longest_word(character varying) RETURNS integer
    AS 'SELECT max(word) FROM (SELECT char_length(regexp_split_to_table($1, '' '')) AS word) A;'
    LANGUAGE SQL
    IMMUTABLE
    RETURNS NULL ON NULL INPUT;

CREATE OR REPLACE FUNCTION names_match(character varying, character varying) RETURNS boolean
    AS 'SELECT CASE WHEN unaccent(lower(regexp_replace(trim(regexp_replace($1, ''[-_]'', '' '')), ''[^A-Za-z ]'', ''''))) =  unaccent(lower(regexp_replace(trim(regexp_replace($2, ''[-_]'', '' '')), ''[^A-Za-z ]'', ''''))) THEN TRUE ELSE FALSE END;'
    LANGUAGE SQL
    IMMUTABLE
    RETURNS NULL ON NULL INPUT;

CREATE OR REPLACE FUNCTION looks_like_a_name(character varying) RETURNS boolean
    AS 'SELECT CASE WHEN regexp_replace(unaccent($1), $$[^''A-Za-z0-9 -]$$, '''') SIMILAR TO $$[A-Z](|[^A-Z]+)(|([ -]([A-Za-z]|[A-Za-z''][a-z.''])+)+)$$ THEN TRUE ELSE FALSE END;'
    LANGUAGE SQL
    IMMUTABLE
    RETURNS NULL ON NULL INPUT;
   