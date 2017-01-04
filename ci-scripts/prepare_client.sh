#!/bin/sh
set -e

# ---------------------------------------------------------------------------- #
#
# Prepare client.
#
# ---------------------------------------------------------------------------- #

# Check the current build.
if [ -z ${BUILD_CLIENT+x} ] || [ "$BUILD_CLIENT" -ne 1 ]; then
 exit 0;
fi

# $TRAVIS_BUILD_DIR/sysconfcpus/bin/sysconfcpus -n 2 elm-make .client/src/elm/TestRunner.elm --output test.html
