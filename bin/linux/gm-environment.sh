#!/bin/bash

localHostname=$(hostname -d)

if [[ "$localHostname" =~ .*\.amazonaws\.com ]] || [[ "$localHostname" =~ .*\.compute\.internal ]]
then
	echo aws
else
	echo vbox
fi
