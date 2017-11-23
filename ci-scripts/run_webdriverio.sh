#!/usr/bin/env bash
set -e

# We should not run the current test under the WebDriverIO build.
if [ "${BUILD_WEBDRIVERIO}" -ne 1 ]; then
 exit 0;
fi

# Load helper functionality.
source ci-scripts/helper_functions.sh


print_message "Test WebDriverIO."
cd "$ROOT_DIR"/client

# Backup verbatim config.
WDIO_CONF=wdio.conf.travis.js
cp "$WDIO_CONF" "$WDIO_CONF".orig

WDIO_ALL_RET=0
declare -a WDIO_FAILED_SPECS
set +o errexit
set -o pipefail
for SPEC in test/specs/*js; do
  print_message "Executing $SPEC"
  WDIO_RET=0
  SPEC_BASENAME=$(echo "$SPEC" | cut -d '/' -f 3 | cut -d '.' -f 1)
  sed "s/<<SPECNAME>>/$SPEC_BASENAME/" < $WDIO_CONF.orig > "$WDIO_CONF"
  for i in $(seq 3); do
    ./node_modules/.bin/wdio "$WDIO_CONF" --spec "$SPEC"  2>&1 | tee /tmp/"$SPEC_BASENAME"-"$i".txt
    WDIO_CMD_RET=$?
    if grep -E -i "(Debug errors appears, due to an error)" /tmp/"$SPEC_BASENAME"-"$i".txt; then
      WDIO_RET=1
    else
      WDIO_RET=$WDIO_CMD_RET
    fi
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
    break
  fi
done

# If WDIO failed, check Watchdog and check if we can access the backend.
if [[ $WDIO_ALL_RET -ne 0 ]]; then
  print_error_message "There are at least one failing specs. See debug details and list below"
  cd "$ROOT_DIR"/server/www
  export PATH="$HOME/.composer/vendor/bin:$PATH"
  drush cc drush
  drush watchdog-show
  curl -D - http://server.local/
  print_error_message "List of failed specs"
  for SPEC in "${WDIO_FAILED_SPECS[@]}"
  do
    print_error_message "$SPEC"
  done;
fi

source "$ROOT_DIR/ci-scripts/post_cache.sh"

exit $WDIO_ALL_RET