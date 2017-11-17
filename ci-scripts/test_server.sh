#!/bin/bash
set -euo pipefail

# ---------------------------------------------------------------------------- #
#
# Run the WebDriverIO tests.
#
# ---------------------------------------------------------------------------- #

# Check the current build.
if [ -z "${BUILD_WEBDRIVERIO+x}" ] || [ "$BUILD_WEBDRIVERIO" -ne 1 ]; then
 exit 0;
fi

mkdir -p /tmp/test_results

if ! bash ci-scripts/run_webdriverio.sh
then
  source "$TRAVIS_BUILD_DIR"/server/travis.config.sh

  echo "The Webdriver.io test failed"
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
    echo "Uploading $DB_FILE, it contains a failed test"
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
    echo "Failed to detect related GitHub issue"
  else
    echo "Detected issue: $PR_URL. Posting GitHub comment..."
    ! curl -H "Authorization: token $GH_TOKEN" --data @$GH_COMMENT "$PR_URL"/comments
  fi
  exit 1
fi

exit 0
