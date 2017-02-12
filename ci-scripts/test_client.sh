#!/bin/sh
set -e

# ---------------------------------------------------------------------------- #
#
# Test client.
#
# ---------------------------------------------------------------------------- #

# Check the current build.
if [ -z ${BUILD_CLIENT+x} ] || [ "$BUILD_CLIENT" -ne 1 ]; then
 exit 0;
fi

# We should not run the current test under the WebDriverIO build.
if [ ${BUILD_WEBDRIVERIO} ] && [ "$BUILD_WEBDRIVERIO" -e 1 ]; then
 exit 0;
fi

cd $TRAVIS_BUILD_DIR/client
elm-test ./src/elm/TestRunner.elm
