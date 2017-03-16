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
./node_modules/.bin/wdio wdio.conf.travis.js |:

# If WDIO failed, check Watchdog and check if we can access the backend.
if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
  cd $ROOT_DIR/server/www
  drush drush watchdog-show
  curl -D - http://server.local/
fi
exit ${PIPESTATUS[0]}
