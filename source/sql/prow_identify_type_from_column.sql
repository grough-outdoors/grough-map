UPDATE
	"__TABLENAME__"
SET
	_prow_type=
	CASE WHEN lower("__COLUMNNAME__") LIKE '%restricted%' OR lower("__COLUMNNAME__") = 'rst bywa' 
	     THEN 'Restricted byway' 
	     WHEN lower("__COLUMNNAME__") LIKE '%boat%' OR lower("__COLUMNNAME__") = 'boat' OR lower("__COLUMNNAME__") LIKE '%byway%'
	     THEN 'Byway open to all traffic'
	     WHEN lower("__COLUMNNAME__") LIKE '%bridle%' OR lower("__COLUMNNAME__") LIKE '%br%d%way%'
	     THEN 'Bridleway'
	     WHEN lower("__COLUMNNAME__") LIKE '%permissive%'
	     THEN 'Permissive path'
	     WHEN lower("__COLUMNNAME__") LIKE '%footpath%'
	     THEN 'Public footpath'
	     ELSE _prow_type
	END;

UPDATE
	"__TABLENAME__"
SET
	_prow_type=
	CASE WHEN lower("__COLUMNNAME__") = 'rb' OR lower("__COLUMNNAME__") = 'rupp' OR lower("__COLUMNNAME__") ~ 'rb[^a-z]' 
	     THEN 'Restricted byway'
	     WHEN lower("__COLUMNNAME__") = 'bw' OR lower("__COLUMNNAME__") = 'br' OR lower("__COLUMNNAME__") ~ 'bw[^a-z]'
	     THEN 'Bridleway'
	     WHEN lower("__COLUMNNAME__") = 'by' OR lower("__COLUMNNAME__") ~ 'bt[^a-z]' OR lower("__COLUMNNAME__") LIKE '%road%'
	     THEN 'Byway open to all traffic'
	     WHEN lower("__COLUMNNAME__") = 'fp' OR lower("__COLUMNNAME__") ~ 'fp[^a-z]'
	     THEN 'Public footpath'
	     ELSE _prow_type
	END
WHERE
	_prow_type = 'Unknown' OR _prow_type IS NULL;
	