#!/usr/bin/env bash

# Load helper functionality.
source helper_functions.sh

# Check the current build.
if [ -z "${BUILD_WEBDRIVERIO+x}" ] || [ "$BUILD_WEBDRIVERIO" -ne 1 ]; then
 exit 0;
fi

# Various dependencies to complete the steps below.
# bzip2: uncompress phantomjs
# g++4.8 - Fibers issue
apt-get -y install g++-4.8 bzip2
# Fibers Node 7.x issue: https://github.com/laverdet/node-fibers/issues/331
export CXX=g++-4.8

# Install global packages.
npm install -g elm@~0.18.0

cd "$ROOT_DIR"/client || exit 1
npm install
bower install --allow-root

elm-package install -y
cp "$ROOT_DIR"/ci-scripts/docker_files/LocalConfig.elm src/elm/LocalConfig.elm

# Since we updated the JAVA version we should rebuild the node-sass.
npm rebuild node-sass
# Run gulp in the background.
gulp &
# But wait for the availability of the app.
until (curl --output /dev/null --silent --head --fail http://localhost:3000); do sleep 1; done
