#!/bin/bash

echo "Refreshing dependencies and config...." >&2
composer install --working-dir="./../"
drush -y --root=./../www cache-rebuild
drush -y --root=./../www updatedb
drush -y --root=./../www config-import
drush -y --root=./../www entup