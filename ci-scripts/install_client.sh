#!/bin/bash
set -e

# ---------------------------------------------------------------------------- #
#
# Install client dependencies and run gulp.
#
# ---------------------------------------------------------------------------- #

# Load helper functionality.
source ci-scripts/helper_functions.sh

echo -e "Host github.com\n\tStrictHostKeyChecking no\n" >> ~/.ssh/config

# Install global packages.
npm install -g elm@~0.18.0
npm install -g elm-test@0.18.2
npm install -g bower@~1.8.2
npm install -g gulp@~3.9.1


cd "$TRAVIS_BUILD_DIR"/client
cp ../ci-scripts/LocalConfig.elm src/elm/LocalConfig.elm
npm install
bower install --allow-root
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

# Run gulp in the background.
gulp &
# But wait for the availability of the app.
c=0
until (curl --output /dev/null --silent --head --fail http://localhost:3000); do
  ((c++)) && ((c==180)) && exit 1
  sleep 1
done
print_message "The webserver on port 3000 became available"
