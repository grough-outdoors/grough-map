CREATE OR REPLACE VIEW source_extended AS
SELECT
	s.*,
	l.licence_name,
	l.licence_url
FROM
	source s
LEFT JOIN
	licence l
ON
	s.source_licence = l.licence_short
ORDER BY
	Count(source_id) OVER (PARTITION BY source_name) ASC,
	Count(source_id) OVER (PARTITION BY source_category) ASC,
	source_org ASC;
	
ALTER TABLE source_extended OWNER TO "grough-map";
