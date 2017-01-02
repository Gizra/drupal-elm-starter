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

cd $TRAVIS_BUILD_DIR/client
$TRAVIS_BUILD_DIR/sysconfcpus/bin/sysconfcpus -n 2 elm-make ./src/elm/TestRunner.elm --output test.html
http-server '.' &

# Wait for compilation is done.
until $(curl --output /dev/null --silent --head --fail http://127.0.0.1:8080/test.html); do echo "." && sleep 1; done
