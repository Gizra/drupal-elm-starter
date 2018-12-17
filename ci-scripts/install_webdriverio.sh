#!/usr/bin/env bash

# Load helper functionality.
source ci-scripts/helper_functions.sh

# Install WDIO.
cd "$ROOT_DIR"/wdio || exit 1
npm install
