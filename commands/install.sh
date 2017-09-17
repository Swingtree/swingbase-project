#!/bin/bash

echo "Reading config...." >&2

# Load the config
. 'conf/si.cfg'
. 'conf/sc.cfg'

# Define a variable that will tell if initialisation needed
require_init=false

# Parse all site-install variables
for var in "${!si@}"; do
	if [[ -z "${!var}" ]]; then
		require_init=true
	fi
done

# If initialisation required
if [[ "$require_init"=true ]]; then
	# Run the initilisation script
	'./conf/init.sh'
	
	# Reload configuration files
	. 'conf/si.cfg'
fi


# install composer dependencies
echo "Installing composer dependencies"
composer install --working-dir="./../"


# Build install command
drush_install_cmd=( drush site-install swingbase --root=./../www -y ) 
for var in "${!si@}"; do
	drush_option_value="${var/si_/--}"
	drush_option_value="${drush_option_value//_/-}"
	drush_option_value="${drush_option_value}"'='"${!var}"
	drush_install_cmd+=("$drush_option_value")
done

# Execute the drush install-site command
echo "Drush Site Installation with configured variables";
"${drush_install_cmd[@]}"


# If the site-uuid is not yet stored in config file
if [[ -z "${sc_uuid}" ]]; 
then
	# Get the freshly create site uuid
	sc_uuid=`drush cget system.site uuid --root=./../www`
	sc_uuid="${sc_uuid#\'system.site:uuid\': }"
	
	# Store it as config
	echo "Site UUID Stored in config"
	sed -i -e 's/sc_uuid=""/sc_uuid="'"${sc_uuid}"'"/' 'conf/sc.cfg'
	
	echo "Exporting initial Drupal 8 config files"
	drush cex --root=./../www -y
else
	# If the site-uuid was already stored in config file
	
	echo "Synchronizing site-uuid from stored config file"
	drush cset system.site uuid $sc_uuid --root=./../www -y
	
	echo "Initiate a Drupal 8 configuration import"
	drush cim --root=./../www -y
fi

echo "Install.sh command finished"
