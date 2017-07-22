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
