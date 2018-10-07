#!/usr/bin/env bash

# Load helper functionality.
source ci-scripts/helper_functions.sh

# Install global packages.
npm install -g elm@~0.18.0
npm install -g bower@~1.8.2
npm install -g gulp@~3.9.1

# Install WDIO.
cd "$ROOT_DIR"/wdio || exit 1
npm install

cd "$ROOT_DIR"/client || exit 1
npm install
bower install --allow-root

elm-package install -y
cp "$ROOT_DIR"/ci-scripts/LocalConfig.elm src/elm/LocalConfig.elm

# Run gulp in the background.
gulp &
# But wait for the availability of the app.
c=0
until (curl --output /dev/null --silent --head --fail http://localhost:3000); do
  ((c++)) && ((c==180)) && exit 1
  sleep 1
done
print_message "The webserver on port 3000 became available"
