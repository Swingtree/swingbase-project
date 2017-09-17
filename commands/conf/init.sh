#!/bin/bash

echo "Initialisating configuration variables..." >&2

# Load the config
. 'conf/si.cfg'

# Parse all site-install variables
for var in "${!si@}"; do
	if [[ -z "${!var}" ]]; then
		input=""
		while [[ -z $input ]]
		do
			echo -n 'Define the value of '"${var} :"
			read input
		done
		sed -i -e 's/'"${var}"'=""/'"${var}"'="'"$input"'"/' conf/si.cfg
	fi
done