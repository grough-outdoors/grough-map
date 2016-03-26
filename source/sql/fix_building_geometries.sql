UPDATE raw_osoml_buildings
SET geom = CASE WHEN ST_GeometryType( ST_Multi( ST_SimplifyPreserveTopology( ST_MakeValid( geom ), 0.1 ) ) ) != 'ST_MultiPolygon' THEN NULL 
           ELSE ST_Multi( ST_SimplifyPreserveTopology( ST_MakeValid( geom ), 0.1 ) )
           END
WHERE ST_IsValid( geom ) = false;