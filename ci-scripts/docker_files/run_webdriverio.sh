#!/usr/bin/env bash
set -e

# We should not run the current test under the WebDriverIO build.
if [ ${BUILD_WEBDRIVERIO} -ne 1 ]; then
 exit 0;
fi

# Load helper functionality.
source helper_functions.sh

print_message "Test WebDriverIO."
cd $ROOT_DIR/client
./node_modules/.bin/wdio wdio.conf.travis.js ||:

# Temporarily upload all the errorShots for debugging purpose
cd $ROOT_DIR/client/errorShots
for i in *png
do
  curl -F "UPLOADCARE_PUB_KEY=2feea389439b60a811f3" \
       -F "UPLOADCARE_STORE=1" \
       -F "file=@$i" \
       "https://upload.uploadcare.com/base/"
done;
