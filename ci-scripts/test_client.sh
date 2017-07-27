#!/bin/sh
set -e

# ---------------------------------------------------------------------------- #
#
# Test client.
#
# ---------------------------------------------------------------------------- #

# Check the current build.
if [ -z "${BUILD_CLIENT+x}" ] || [ "$BUILD_CLIENT" -ne 1 ]; then
 exit 0;
fi

cd "$TRAVIS_BUILD_DIR"/client
npm test

# Run galen tests.
npm run galen -- check ./test/galen/login.gspec --url http://server.local:3000 --size 640x480 --config ./test/galen/galen.travis.config