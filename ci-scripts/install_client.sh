#!/bin/bash
set -e

# ---------------------------------------------------------------------------- #
#
# Install client dependencies.
#
# ---------------------------------------------------------------------------- #

# Check the current build.
if [ -z "${BUILD_CLIENT+x}" ] || [ "$BUILD_CLIENT" -ne 1 ]; then
 exit 0;
fi

echo -e "Host github.com\n\tStrictHostKeyChecking no\n" >> ~/.ssh/config

# Install global packages.
npm install -g elm@~0.18.0
npm install -g elm-test@0.18.2

cd "$TRAVIS_BUILD_DIR"/client
elm-package install -y
