#!/bin/bash

outputType=`echo "$1" | tr '[:lower:]' '[:upper:]'`
outputHTML="/vagrant/product/SOURCES.htm"
outputTXT="/vagrant/product/SOURCES.txt"

function writeSourceRecord {
	if [[ "$outputType" = "TXT" ]]; then
		writeSourceRecordTXT "$1"
	fi
	if [[ "$outputType" = "HTML" ]]; then
		writeSourceRecordHTML "$1"
	fi
}

function writeFile {
	if [[ "$outputType" = "TXT" ]]; then
		writeTXT "$1"
	fi
	if [[ "$outputType" = "HTML" ]]; then
		writeHTML "$1"
	fi
}

function writeHeader {
	if [[ "$outputType" = "TXT" ]]; then
		writeHeaderTXT "$1"
	fi
	if [[ "$outputType" = "HTML" ]]; then
		writeHeaderHTML "$1"
	fi
}

function writeFooter {
	if [[ "$outputType" = "TXT" ]]; then
		writeFooterTXT "$1"
	fi
	if [[ "$outputType" = "HTML" ]]; then
		writeFooterHTML "$1"
	fi
}

function writeFile {
	if [[ "$outputType" = "TXT" ]]; then
		writeTXT "$1"
	fi
	if [[ "$outputType" = "HTML" ]]; then
		writeHTML "$1"
	fi
}

function writeHeaderTXT {
	echo "" > "${outputTXT}"
	writeTXT ""
}

function writeSourceRecordTXT {
	constraintList=`echo "${sourceValues[source_constraints]}" | sed -e 's/","/|/g' -e 's/[{}"]//g'`
	disclaimerList=`echo "${sourceValues[source_disclaimers]}" | sed -e 's/","/|/g' -e 's/[{}"]//g'`
	IFS='|' read -r -a sourceConstraints <<< "${constraintList}"
	IFS='|' read -r -a sourceDisclaimers <<< "${disclaimerList}"
	
	if [[ ${lastSourceOrg} != ${sourceValues[source_org]} ]]; then
		lastSourceOrg=${sourceValues[source_org]}
		writeFile "  "`echo "${lastSourceOrg}" | tr '[:lower:]' '[:upper:]'`" ("${sourceValues[source_url]}")"
		writeFile "  "${sourceValues[source_category]}
		writeFile ""
	fi
	
	writeFile "   - ${sourceValues[source_name]}"
	writeFile "     ${sourceValues[source_statement]}"
	writeFile ""
	writeFile "     Licensed under ${sourceValues[licence_name]}."
	writeFile "     ${sourceValues[licence_url]}"
	writeFile ""
	if [[ -z "${sourceValues[source_date]}" ]]; then
		writeFile "     Date of the data is unknown."
	else
		writeFile "     Data archived on ${sourceValues[source_date]}."
	fi
	writeFile ""
	if [[ "${#sourceConstraints[@]}" -gt 0 ]]; then
		writeFile "     Constraints:"
		for Z in "${sourceConstraints[@]}"; do
			writeFile "       - ${Z}"
		done
		writeFile ""
	fi
	if [[ "${#sourceDisclaimers[@]}" -gt 0 ]]; then
		writeFile "     Disclaimers:"
		for Z in "${sourceDisclaimers[@]}"; do
			writeFile "       - ${Z}"
		done
		writeFile ""
	fi
	writeFile ""
}

function writeFooterTXT {
	writeTXT ""
}

function writeHeaderHTML {
	echo "" > "${outputHTML}"
	writeHTML "<html>"
	writeHTML "    <head>"
	writeHTML "
		<style>
			body {
				font-family: sans-serif;
				max-width: 1000px;
				margin: 0 auto;
			}
			
			h1 {
				font-size: 1.7em;
				margin-top: 2em;
				margin-bottom: 0;
			}
			
			h2 {
				font-size: 1.25em;
				margin-top: 1.25em;
			}
			
			h2:first-child {
				margin-top: 0;
			}
			
			h3 {
				font-size: 1em;
			}
			
			.org-url {
				font-size: 80%;
			}
			
			.org-description {
				font-weight: bold;
				font-size: 1.25em;
				margin-bottom: 1em;
				margin-top: 0;
			}
		</style>
	"
	writeHTML "    </head>"
	writeHTML "    <body>"
}

function writeSourceRecordHTML {
	constraintList=`echo "${sourceValues[source_constraints]}" | sed -e 's/","/|/g' -e 's/[{}"]//g'`
	disclaimerList=`echo "${sourceValues[source_disclaimers]}" | sed -e 's/","/|/g' -e 's/[{}"]//g'`
	IFS='|' read -r -a sourceConstraints <<< "${constraintList}"
	IFS='|' read -r -a sourceDisclaimers <<< "${disclaimerList}"
	
	if [[ ${lastSourceOrg} != ${sourceValues[source_org]} ]]; then
		lastSourceOrg=${sourceValues[source_org]}
		writeFile "        <h1>${lastSourceOrg} <span class=\"org-url\">(<a href=\"${sourceValues[source_url]}\">"${sourceValues[source_url]}"</a>)</span></h1>"
		writeFile "        <p class=\"org-description\">${sourceValues[source_category]}</p>"
	fi
	
	writeFile ""
	writeFile "            <h2>${sourceValues[source_name]}</h2>"
	writeFile "            <p class=\"ds-copyright\">"`echo "${sourceValues[source_statement]}" | sed -e 's/©/\&copy\;/g'`"</p>"
	writeFile ""
	writeFile "            <p class=\"ds-licence\">Licensed under <a href=\"${sourceValues[licence_url]}\">${sourceValues[licence_name]}</a>.</p>"
	writeFile ""
	if [[ -z "${sourceValues[source_date]}" ]]; then
		writeFile "            <p class=\"ds-date\">Date of the data is unknown.</p>"
	else
		writeFile "            <p class=\"ds-date\">Data archived on ${sourceValues[source_date]}.</p>"
	fi
	writeFile ""
	if [[ "${#sourceConstraints[@]}" -gt 0 ]]; then
		writeFile "            <h3 class=\"ds-constraints-hdg\">Constraints:</h3>"
		writeFile "            <ul class=\"ds-constraints\">"
		for Z in "${sourceConstraints[@]}"; do
			writeFile "              <li>${Z}</li>"
		done
		writeFile "            </ul>"
	fi
	if [[ "${#sourceDisclaimers[@]}" -gt 0 ]]; then
		writeFile "            <h3 class=\"ds-disclaimers-hdg\">Disclaimers:</h3>"
		writeFile "            <ul class=\"ds-disclaimers\">"
		for Z in "${sourceDisclaimers[@]}"; do
			writeFile "              <li>${Z}</li>"
		done
		writeFile "            </ul>"
	fi
	writeFile ""
}

function writeFooterHTML {
	writeHTML "    </body>"
	writeHTML "</html>"
}

function writeHTML {
	echo "$1" >> "$outputHTML"
}

function writeTXT {
	echo "$1" >> "$outputTXT"
}

sourceHeader=`psql -A -Ugrough-map grough-map -h 127.0.0.1 -c "SELECT * FROM source_extended LIMIT 1" | head -1`
IFS='|'; read -r -a sourceColumns <<< "$sourceHeader"

lastSourceOrg=""

writeHeader

IFS=$'\n'; for sourceRow in `psql -A -t -Ugrough-map grough-map -h localhost -c "
	SELECT * FROM source_extended;
"`;
do
	declare -A sourceValues
	IFS='|'; read -r -a sourceArray <<< "$sourceRow"

	for (( I=0; $I < ${#sourceColumns[@]}; I+=1 ))
	do 
		sourceValues[${sourceColumns[$I]}]=${sourceArray[$I]}
	done
	
	writeSourceRecord ${sourceValues}
done

writeFooter
