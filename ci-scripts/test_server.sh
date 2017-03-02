#!/bin/sh
set -e

# ---------------------------------------------------------------------------- #
#
# Run the Behat/WebDriverIO tests.
#
# ---------------------------------------------------------------------------- #

# Check the current build.
if [ -z ${BUILD_SERVER+x} ] || [ "$BUILD_SERVER" -ne 1 ]; then
 exit 0;
fi

# Set 'BUILD_WEBDRIVERIO' in case it is not defined.
if [ -z ${BUILD_WEBDRIVERIO+x} ]; then
 BUILD_WEBDRIVERIO=0
fi

cd ci-scripts/docker_files
docker-compose up
