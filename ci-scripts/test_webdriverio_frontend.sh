#!/usr/bin/env bash
set -e
# ---------------------------------------------------------------------------- #
#
# Run the Webdriver.IO test.
#
# ---------------------------------------------------------------------------- #

# Load helper functionality.
source ci-scripts/helper_functions.sh


print_message "Test WebDriverIO for the frontend."
cd "$ROOT_DIR"/wdio
npm install

cd "$ROOT_DIR"/wdio/travis-conf

# Backup verbatim config.
WDIO_CONF=wdio.conf.frontend.travis.js
cp "$WDIO_CONF" "$WDIO_CONF".orig

WDIO_ALL_RET=0
declare -a WDIO_FAILED_SPECS
set +o errexit
cd "$ROOT_DIR"/wdio

for SPEC in specs/frontend/*js; do
  print_message "Executing $SPEC"
  WDIO_RET=0
  SPEC_BASENAME=$(echo "$SPEC" | cut -d '/' -f 2 | cut -d '.' -f 1)
  sed "s/<<SPEC_NAME>>/$SPEC_BASENAME/" < ./travis-conf/$WDIO_CONF.orig > ./travis-conf/"$WDIO_CONF"
  for i in $(seq 3); do
    "$ROOT_DIR"/wdio/node_modules/.bin/wdio ./travis-conf/"$WDIO_CONF" --spec "$SPEC"
    WDIO_RET=$?
    if [[ "$WDIO_RET" -eq 0 ]]; then
      # We give 3 chances to complete
      # but of course we quit on first success
      break
    fi
    print_error_message "$SPEC failed for the attempt ($i.), retrying..."
  done
  if [[ "$WDIO_RET" -ne 0 ]]; then
    print_error_message "$SPEC failed"
    echo "$SPEC_BASENAME" >> /tmp/test_results/failed_tests
    WDIO_ALL_RET="$WDIO_RET"
    WDIO_FAILED_SPECS+=("$SPEC")
  fi
done

# If WDIO failed, check Watchdog and check if we can access the backend.
if [[ $WDIO_ALL_RET -ne 0 ]]; then
  print_error_message "There are at least one failing specs. See debug details and list below"
  cd "$ROOT_DIR"/server/www
  export PATH="$HOME/.composer/vendor/bin:$PATH"
  drush cc drush
  drush watchdog-show
  curl -D - http://127.0.0.1:8080
  print_error_message "List of failed specs"
  for SPEC in "${WDIO_FAILED_SPECS[@]}"
  do
    print_error_message "$SPEC"
  done;

fi
exit $WDIO_ALL_RET
