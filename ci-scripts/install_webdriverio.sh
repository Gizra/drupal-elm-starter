#!/usr/bin/env bash

# Load helper functionality.
source ci-scripts/helper_functions.sh

# Install Chromedriver.
wget -nv https://chromedriver.storage.googleapis.com/74.0.3729.6/chromedriver_linux64.zip
unzip chromedriver_linux64.zip
nohup ./chromedriver &

# Install WDIO.
cd "$ROOT_DIR"/wdio || exit 1
npm install
