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

WDIO_ALL_RET=0
set +o errexit
for SPEC in test/specs/*js; do
  echo "---------"
  echo "Executing $SPEC"
  echo "---------"
  echo ""
  WDIO_RET=0
  for i in `seq 3`; do
    ./node_modules/.bin/wdio wdio.conf.travis.js --spec $SPEC
    WDIO_RET=$?
    if [[ $WDIO_RET -eq 0 ]]; then
      # We give 3 chances to complete
      # but of course we quit on first success
      break
    fi
    echo "$SPEC failed for the attempt ($i.), retrying..."
  done
  if [[ $WDIO_RET -ne 0 ]]; then
    echo "$SPEC failed"
    WDIO_ALL_RET=$WDIO_RET
  fi
done

# If WDIO failed, check Watchdog and check if we can access the backend.
if [[ $WDIO_ALL_RET -ne 0 ]]; then
  cd $ROOT_DIR/server/www
  export PATH="$HOME/.composer/vendor/bin:$PATH"
  drush cc drush
  drush watchdog-show
  curl -D - http://server.local/
fi
exit $WDIO_ALL_RET
