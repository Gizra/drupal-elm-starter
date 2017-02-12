#!/bin/sh
set -e

# ---------------------------------------------------------------------------- #
#
# Run the behat tests.
#
# ---------------------------------------------------------------------------- #

# Check the current build.
if [ -z ${BUILD_SERVER+x} ] || [ "$BUILD_SERVER" -ne 1 ]; then
 exit 0;
fi

# We should not run the current test under the WebDriverIO build.
if [ ${BUILD_WEBDRIVERIO} ] && [ "$BUILD_WEBDRIVERIO" -e 1 ]; then
 exit 0;
fi

docker run -it -p 8080:80 server
