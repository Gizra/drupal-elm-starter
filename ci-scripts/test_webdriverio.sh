#!/usr/bin/env bash
set -e

# We should not run the current test under the WebDriverIO build.
if [ "${BUILD_WEBDRIVERIO}" -ne 1 ]; then
 exit 0;
fi

# Load helper functionality.
source ci-scripts/helper_functions.sh


print_message "Test WebDriverIO."
mkdir -p /tmp/test_results
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
  print_error_message "The Webdriver.io test failed"
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

  source "$TRAVIS_BUILD_DIR"/server/travis.config.sh

  cd /tmp
  ! rm gdrive-linux-x64.zip
  wget https://github.com/prasmussen/gdrive/files/879060/gdrive-linux-x64.zip
  unzip gdrive-linux-x64.zip
  chmod +x ./gdrive
  mkdir ~/.gdrive
  cp "$TRAVIS_BUILD_DIR"/gdrive-service-account.json ~/.gdrive/
  export PATH="$HOME/.composer/vendor/bin:$PATH"
  GH_COMMENT=/tmp/db_urls
  echo -n '{
  "body": "' >> $GH_COMMENT

    cd "$TRAVIS_BUILD_DIR/server/www"
    DB_FILE="drupal.sql"
    drush sql-dump > "$DB_FILE"
    gzip "$DB_FILE"
    FAILED_SPEC=$(</tmp/test_results/failed_tests)
    print_message "Uploading $DB_FILE, it contains a failed test"
    ID=$(/tmp/gdrive upload --service-account gdrive-service-account.json "$DB_FILE.gz" | tail -n1 | cut -d ' ' -f 2)
    /tmp/gdrive share --service-account gdrive-service-account.json "$ID"
    URL=$(/tmp/gdrive info --service-account gdrive-service-account.json "$ID" | grep ViewUrl | sed s/ViewUrl:\ //)
    echo -n "* DB dump after the failed WebdriverIO test [$FAILED_SPEC]($URL)." | tee -a $GH_COMMENT
    echo ""
    printf '\\n' >> $GH_COMMENT

  echo '"}' >> $GH_COMMENT

  # Todo: make it non-Gizra specific by detecting the user of the repository.
  PR_URL=$(curl -H "Authorization: token $GH_TOKEN" -s  https://api.github.com/repos/"$GH_REPO"/pulls?head=Gizra:"${TRAVIS_PULL_REQUEST_BRANCH:-$TRAVIS_BRANCH}" | grep '"url"' | head -n1  | cut -d'"' -f 4)
  PR_URL=${PR_URL/\/pulls\//\/issues\/}
  if [[ -z "${PR_URL// }" ]]; then
    print_error_message "Failed to detect related GitHub issue"
  else
    print_message "Detected issue: $PR_URL. Posting GitHub comment..."
    ! curl -H "Authorization: token $GH_TOKEN" --data @$GH_COMMENT "$PR_URL"/comments
  fi
fi

source "$ROOT_DIR/ci-scripts/post_cache.sh"

exit $WDIO_ALL_RET
