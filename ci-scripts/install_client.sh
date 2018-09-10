#!/bin/bash
set -e

# ---------------------------------------------------------------------------- #
#
# Install client dependencies.
#
# ---------------------------------------------------------------------------- #

echo -e "Host github.com\n\tStrictHostKeyChecking no\n" >> ~/.ssh/config

# Install global packages.
npm install -g elm@~0.18.0
npm install -g elm-test@0.18.2

cd "$TRAVIS_BUILD_DIR"/client
cp ../ci-scripts/LocalConfig.elm src/elm/LocalConfig.elm
elm-package install -y


# Getting elm-make to run quicker.
# See https://github.com/elm-lang/elm-compiler/issues/1473#issuecomment-245704142
if [ ! -d sysconfcpus/bin ];
then
  git clone https://github.com/obmarg/libsysconfcpus.git;
  cd libsysconfcpus || exit;
  ./configure --prefix="$TRAVIS_BUILD_DIR"/sysconfcpus;
  make && make install;
  pwd
  cd ..;
fi
