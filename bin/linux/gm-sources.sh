#!/bin/bash

echo ""

sourceHeader=`psql -A -Ugrough-map grough-map -h 127.0.0.1 -c "SELECT * FROM source_extended LIMIT 1" | head -1`
IFS='|'; read -r -a sourceColumns <<< "$sourceHeader"

lastSourceOrg=""

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
	
	constraintList=`echo "${sourceValues[source_constraints]}" | sed -e 's/","/|/g' -e 's/[{}"]//g'`
	disclaimerList=`echo "${sourceValues[source_disclaimers]}" | sed -e 's/","/|/g' -e 's/[{}"]//g'`
	IFS='|' read -r -a sourceConstraints <<< "${constraintList}"
	IFS='|' read -r -a sourceDisclaimers <<< "${disclaimerList}"
	
	if [[ ${lastSourceOrg} != ${sourceValues[source_org]} ]]; then
		lastSourceOrg=${sourceValues[source_org]}
		echo "  "`echo ${lastSourceOrg} | tr '[:lower:]' '[:upper:]'`" ("${sourceValues[source_url]}")"
		echo "  "${sourceValues[source_category]}
		echo ""
	fi
	
	echo "   - ${sourceValues[source_name]}"
	echo "     ${sourceValues[source_statement]}"
	echo ""
	echo "     Licensed under ${sourceValues[licence_name]}"
	echo "     ${sourceValues[licence_url]}"
	echo ""
	if [[ -z "${sourceValues[source_date]}" ]]; then
		echo "     Date of the data is unknown"
	else
		echo "     Data archived on ${sourceValues[source_date]}"
	fi
	echo ""
	if [[ "${#sourceConstraints[@]}" -gt 0 ]]; then
		echo "     Constraints:"
		for Z in "${sourceConstraints[@]}"; do
			echo "       - ${Z}"
		done
		echo ""
	fi
	if [[ "${#sourceDisclaimers[@]}" -gt 0 ]]; then
		echo "     Disclaimers:"
		for Z in "${sourceDisclaimers[@]}"; do
			echo "       - ${Z}"
		done
		echo ""
	fi
	echo ""
	
done

echo ""