#!/bin/sh
set -e

# ---------------------------------------------------------------------------- #
#
# Run the WebDriverIO tests.
#
# ---------------------------------------------------------------------------- #

# Check the current build.
if [ -z ${BUILD_WEBDRIVERIO+x} ] || [ "$BUILD_WEBDRIVERIO" -ne 1 ]; then
 exit 0;
fi

print_message "Test WebDriverIO."
cd $ROOT_DIR/client
./node_modules/.bin/wdio wdio.conf.js
