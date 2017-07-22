#!/usr/bin/env bash
set -e

# We should not run the current test under the WebDriverIO build.
if [ "${BUILD_WEBDRIVERIO}" -ne 1 ]; then
 exit 0;
fi

# Load helper functionality.
source helper_functions.sh

print_message "Test WebDriverIO."
cd "$ROOT_DIR"/client

# Backup verbatim config.
WDIO_CONF=wdio.conf.travis.js
cp "$WDIO_CONF" "$WDIO_CONF".orig

WDIO_ALL_RET=0
declare -a WDIO_FAILED_SPECS
set +o errexit
for SPEC in test/specs/*js; do
  print_message "Executing $SPEC"
  WDIO_RET=0
  SPEC_BASENAME=$(echo "$SPEC" | cut -d '/' -f 3 | cut -d '.' -f 1)
  sed "s/<<SPECNAME>>/$SPEC_BASENAME/" < $WDIO_CONF.orig > "$WDIO_CONF"
  for i in $(seq 3); do
    ./node_modules/.bin/wdio "$WDIO_CONF" --spec "$SPEC"
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
  curl -D - http://server.local/
  print_error_message "List of failed specs"
  for SPEC in "${WDIO_FAILED_SPECS[@]}"
  do
    print_error_message "$SPEC"
  done;

  # Potentially wait for video encoding ending.
  # ps aux shows all the processes from hosts + other containers.
  COUNT=0
  FFMPEG_COUNT=$(pgrep -c ffmpeg)
  while [[ $FFMPEG_COUNT -ne 0 ]]; do
    FFMPEG_COUNT=$(pgrep -c ffmpeg)
    ((COUNT++)) && ((COUNT==30)) && break
    sleep 5
  done;

fi
exit $WDIO_ALL_RET
