#!/usr/bin/env bash

# Load helper functionality.
source ci-scripts/helper_functions.sh

# Check the current build.
if [ -z "${BUILD_WEBDRIVERIO+x}" ] || [ "$BUILD_WEBDRIVERIO" -ne 1 ]; then
 exit 0;
fi

# Install global packages.
npm install -g elm@~0.18.0
npm install -g bower@~1.8.2
npm install -g gulp@~3.9.1

cd "$ROOT_DIR"/client || exit 1
npm install
bower install --allow-root

elm-package install -y
cp "$ROOT_DIR"/ci-scripts/LocalConfig.elm src/elm/LocalConfig.elm



# Run gulp in the background.
gulp &
# But wait for the availability of the app.
until (curl --output /dev/null --silent --head --fail http://localhost:3000); do sleep 1; done

# Install Google Chrome.
cd /tmp || exit 1
wget http://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_64.0.3282.186-1_amd64.deb
sudo dpkg -i google-chrome-stable_64.0.3282.186-1_amd64.deb
