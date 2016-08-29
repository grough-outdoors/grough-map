#!/bin/bash

binDir=/vagrant/bin/linux/
attributionFile="$1"
attributionDir=`dirname "${attributionFile}"`

sourceString=`cat "$attributionFile" | python -c """
import json, sys, codecs
utfReader = codecs.getreader('utf8')
utfWriter = codecs.getwriter('utf8')
sys.stdin = utfReader(sys.stdin)
sys.stdout = utfWriter(sys.stdout)

obj = json.load(sys.stdin)

sys.stdout.write(obj['dataset'] + '|')
sys.stdout.write(obj['source']['name'] + '|')
sys.stdout.write(obj['source']['category'] + '|')
sys.stdout.write(obj['source']['url'] + '|')
sys.stdout.write(obj['licence']['code'] + '|')
sys.stdout.write(obj['statement'] + '|')
sys.stdout.write(obj['date']['method'] + '|')
if 'value' in obj['date']:
	sys.stdout.write(obj['date']['value'] + '|')
else:
	sys.stdout.write('|')
if 'disclaimers' in obj:
	sys.stdout.write('ARRAY[\'' + '\', \''.join('{0}'.format(w.replace('\'', '\'\'')) for w in obj['disclaimers']) + '\']' + '|')
else:
	sys.stdout.write('ARRAY[]|')
if 'constraints' in obj:
	sys.stdout.write('ARRAY[\'' + '\', \''.join('{0}'.format(w.replace('\'', '\'\'')) for w in obj['constraints']) + '\']')
else:
	sys.stdout.write('ARRAY[]')
""" 2> /dev/null`
IFS='|'; read -r -a sourceInfo <<< "${sourceString}"
dsName="${sourceInfo[0]}"
attributionName="${sourceInfo[1]}"
attributionType="${sourceInfo[2]}"
attributionURL="${sourceInfo[3]}"
attributionLicence="${sourceInfo[4]}"
attributionStatement="${sourceInfo[5]}"
attributionDateMethod="${sourceInfo[6]}"
attributionDateValue="${sourceInfo[7]}"
attributionDisclaimers="${sourceInfo[8]}"
attributionConstraints="${sourceInfo[9]}"

if [[ -z "${dsName}" ||
      -z "${attributionName}" ||
      -z "${attributionType}" ||
      -z "${attributionURL}" ||
      -z "${attributionLicence}" ||
      -z "${attributionStatement}" ||
	  -z "${attributionDisclaimers}" ||
      -z "${attributionConstraints}" ]]; then
	echo "Cannot read attribution data."
	exit 1  
fi	

attributionDate="null"
attributionYear=`date +"%Y"`

if [[ "${attributionDateMethod}" = "archive" ]]; then
	echo "--> Using archive file as date source."
	archiveDate=`unzip -ZlT "${attributionDir}/${attributionDateValue}" | grep -Eo '([0-9]{8}).[0-9]{6}' | grep -Eo '[0-9]{8}' | sort | tail -1`
	attributionYear=`echo "${archiveDate}" | cut -b 1-4`
	attributionDate="to_date('${archiveDate}', 'YYYYMMDD')"
fi

if [[ "${attributionDateMethod}" = "file" ]]; then
	echo "--> Cannot identify date from file accurately."
	attributionYear=`date +"%Y"`
	attributionDate="null"
fi

if [[ "${attributionDateMethod}" = "today" ]]; then
	echo "--> Using today as date source."
	attributionDate="to_date('"`date +"%Y%m%d"`"', 'YYYYMMDD')"
fi

attributionStatement=`echo "${attributionStatement}" | sed -e 's/{YYYY}/'${attributionYear}'/'`

echo "--------------"
echo "  Dataset:           ${dsName}"
echo "  Source attribution"
echo "    Organisation:    ${attributionName}"
echo "    Category:        ${attributionType}"
echo "    URL:             ${attributionURL}"
echo "    Licence type:    ${attributionLicence}"
echo "    Statement:       ${attributionStatement}"
echo "    Date source:     ${attributionDateMethod}"
echo "      using:         ${attributionDateValue}"
echo "      returning:     ${attributionDate}"
echo "    Disclaimers:     ${attributionDisclaimers}"
echo "    Constraints:     ${attributionConstraints}"
echo "--------------"

# TODO: Already exists?
existCheck=`psql -A -t -Ugrough-map grough-map -h 127.0.0.1 -c "
	SELECT source_id FROM source 
	WHERE source_name='${dsName}'
	AND source_org='${attributionName}'
	AND source_category='${attributionType}'
" | head -1`

if [[ ! -z "$existCheck" ]]; then
	echo "--> Updating existing source (ID: ${existCheck})..."
	psql -Ugrough-map grough-map -h 127.0.0.1 > /dev/null <<EoSQL
		UPDATE
			source
		SET
			"source_url" = '${attributionURL}',
			"source_licence" = '${attributionLicence}',
			"source_constraints" = ${attributionConstraints}::text[],
			"source_disclaimers" = ${attributionDisclaimers}::text[],
			"source_statement" = '${attributionStatement}',
			"source_date" = ${attributionDate}
		WHERE
			"source_id"=${existCheck}
		;
EoSQL
else
	echo "--> Adding new source..."
	psql -Ugrough-map grough-map -h 127.0.0.1 > /dev/null <<EoSQL
		INSERT INTO
			source
			(
				"source_name",
				"source_org",
				"source_url",
				"source_licence",
				"source_category",
				"source_constraints",
				"source_disclaimers",
				"source_statement",
				"source_date"
			)
		SELECT
			'${dsName}',
			'${attributionName}',
			'${attributionURL}',
			'${attributionLicence}',
			'${attributionType}',
			${attributionConstraints}::character varying(255)[],
			${attributionDisclaimers}::character varying(255)[],
			'${attributionStatement}',
			${attributionDate}
		RETURNING
			"source_id"
		;
EoSQL
fi

echo "--> Updating complete source lists..."
"${binDir}/gm-sources.sh" TXT
"${binDir}/gm-sources.sh" HTML

echo "  > Done."
