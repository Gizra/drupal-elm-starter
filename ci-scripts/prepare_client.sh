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

$TRAVIS_BUILD_DIR/sysconfcpus/bin/sysconfcpus -n 2 elm-make $TRAVIS_BUILD_DIR/client/src/elm/TestRunner.elm $TRAVIS_BUILD_DIR/client/src/elm/Main.elm --output test.html --yes
cp ./client/src/elm/LocalConfig.Example.elm ./client/src/elm/LocalConfig.elm
