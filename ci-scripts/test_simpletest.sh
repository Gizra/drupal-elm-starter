#!/usr/bin/env bash
set -e

# Load helper functionality.
source ci-scripts/helper_functions.sh

# -------------------------------------------------- #
# Run SimpleTest
# -------------------------------------------------- #
print_message "Run SimpleTest."
export PATH="$HOME/.composer/vendor/bin:$PATH"
cd "$ROOT_DIR"/server/www
drush en simpletest -y
cd "$ROOT_DIR"/server/www
php ./scripts/run-tests.sh --cache --cache-modules --php "$(which php)" --concurrency 2 --verbose --color --url http://127.0.0.1:8080 Hedley 2>&1 | tee /tmp/simpletest-result.txt
grep -E -i "([1-9]+ fail)|(Fatal error)|([1-9]+ exception)|([0-9]+0 fail)|([0-9]+0 exception)" /tmp/simpletest-result.txt && exit 1

exit 0
