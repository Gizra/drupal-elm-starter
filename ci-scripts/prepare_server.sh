#!/bin/sh
set -e

# ---------------------------------------------------------------------------- #
#
# Run the web server.
#
# ---------------------------------------------------------------------------- #

# Check the current build.
if [ -z ${BUILD_SERVER+x} ] || [ "$BUILD_SERVER" -ne 1 ]; then
 exit 0;
fi

# start a web server on port 8080, run in the background; wait for initialization.
echo "Initiate drupal server via drush."
drush @server runserver 127.0.0.1:8080 2>&1 &

echo "Validating the server is up and running via netstat."
until netstat -an 2>/dev/null | grep '8080.*LISTEN'; do true; done
