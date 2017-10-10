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

# Java 8 for recent Selenium.
# https://www.npmjs.com/package/selenium-standalone#ensure-you-have-the-minimum-required-java-version.
echo "deb http://http.debian.net/debian jessie-backports main" >> /etc/apt/sources.list
apt-get update && apt-get install openjdk-8-jre
update-alternatives --config java

# Install global packages.
npm install -g elm@~0.18.0
npm install -g elm-test
npm install -g bower
npm install -g gulp

cd "$ROOT_DIR"/client || exit 1
npm install
bower install --allow-root

elm-package install -y
cp "$ROOT_DIR"/ci-scripts/docker_files/LocalConfig.elm src/elm/LocalConfig.elm

# Getting elm-make to run quicker.
# See https://github.com/elm-lang/elm-compiler/issues/1473#issuecomment-245704142
if [ ! -d sysconfcpus/bin ];
then
  git clone https://github.com/obmarg/libsysconfcpus.git;
  cd libsysconfcpus || exit;
  ./configure --prefix="$ROOT_DIR"/sysconfcpus;
  make && make install;
  pwd
  cd ..;
fi

# Since we updated the JAVA version we should rebuild the node-sass.
npm rebuild node-sass
# Run gulp in the background.
gulp &
# But wait for the availability of the app.
until (curl --output /dev/null --silent --head --fail http://localhost:3000); do sleep 1; done
