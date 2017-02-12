#!/usr/bin/env bash

# Load helper functionality.
source helper_functions.sh

# Check the current build.
if [ -z ${BUILD_WEBDRIVERIO+x} ] || [ "$BUILD_WEBDRIVERIO" -ne 1 ]; then
 exit 0;
fi

echo -e "Host github.com\n\tStrictHostKeyChecking no\n" >> ~/.ssh/config

# Install global packages.
npm install -g elm@~0.18.0
npm install -g elm-test
npm install -g bower

cd $ROOT_DIR/client
npm install
bower install

elm-package install -y

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
