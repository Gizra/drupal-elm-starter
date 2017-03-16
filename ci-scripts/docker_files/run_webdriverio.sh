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
set +o errexit
./node_modules/.bin/wdio wdio.conf.travis.js
WDIO_RET=$?

# If WDIO failed, check Watchdog and check if we can access the backend.
if [[ $WDIO_RET -ne 0 ]]; then
  cd $ROOT_DIR/server/www
  export PATH="$HOME/.composer/vendor/bin:$PATH"
  drush drush watchdog-show
  curl -D - http://server.local/
fi
exit $WDIO_RET
