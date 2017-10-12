#!/usr/bin/env bash
set -e

# We should not run the current test under the WebDriverIO build, but on the server builds.
if [ "${BUILD_WEBDRIVERIO}" == 1 ]; then
 exit 0;
fi
if [ -z "${BUILD_SERVER+x}" ] || [ "$BUILD_SERVER" -ne 1 ]; then
 exit 0;
fi

# Load helper functionality.
source helper_functions.sh

# -------------------------------------------------- #
# Run SimpleTest
# -------------------------------------------------- #
print_message "Run SimpleTest."
export PATH="$HOME/.composer/vendor/bin:$PATH"
drush @server.local en simpletest -y
cd "$ROOT_DIR"/server
php ./www/scripts/run-tests.sh --cache --cache-modules --php "$(which php)" --concurrency 4 --verbose --color --url http://server.local Hedley 2>&1 | tee /tmp/simpletest-result.txt
grep -E -i "([1-9]+ fail)|(Fatal error)|([1-9]+ exception)" /tmp/simpletest-result.txt && exit 1

exit 0
