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

# $TRAVIS_BUILD_DIR/client/sysconfcpus/bin/sysconfcpus -n 2 elm-make ./src/elm/TestRunner.elm
