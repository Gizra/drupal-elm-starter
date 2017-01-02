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

echo "Starting behat tests:"
echo

# Run behat tests
cd $TRAVIS_BUILD_DIR/server/behat
./bin/behat --tags=~@wip
