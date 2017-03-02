#!/usr/bin/env bash

# Load helper functionality.
source helper_functions.sh

# Check the current build.
if [ -z ${BUILD_WEBDRIVERIO+x} ] || [ "$BUILD_WEBDRIVERIO" -ne 1 ]; then
 exit 0;
fi

# Fibers Node 7.x issue: https://github.com/laverdet/node-fibers/issues/331
apt-get -y install g++-4.8
export CXX=g++-4.8

apt-get -y install bzip2

# Install global packages.
npm install -g elm@~0.18.0
npm install -g elm-test
npm install -g bower
npm install -g gulp

cd $ROOT_DIR/client
npm install
bower install --allow-root

elm-package install -y
cp src/elm/LocalConfig.Example.elm src/elm/LocalConfig.elm

# Getting elm-make to run quicker.
# See https://github.com/elm-lang/elm-compiler/issues/1473#issuecomment-245704142
if [ ! -d sysconfcpus/bin ];
then
  git clone https://github.com/obmarg/libsysconfcpus.git;
  cd libsysconfcpus;
  ./configure --prefix=$ROOT_DIR/sysconfcpus;
  make && make install;
  pwd
  cd ..;
fi

# Since we updated the JAVA version we should rebuild the node-sass.
npm rebuild node-sass
# Run gulp in the background.
gulp &
