#!/bin/sh
set -e

# ---------------------------------------------------------------------------- #
#
# Run the behat tests.
#
# ---------------------------------------------------------------------------- #

# Check the current build.
if [ -z ${BUILD_SERVER+x} ] || [ "$BUILD_SERVER" -ne 1 ]; then
 exit 0;
fi

# We should not run the current test under the WebDriverIO build.
if [ ${BUILD_WEBDRIVERIO} ] && [ "$BUILD_WEBDRIVERIO" -e 1 ]; then
 exit 0;
fi

# -------------------------------------------------- #
# Installing Behat.
# -------------------------------------------------- #
print_message "Install behat."
cd $ROOT_DIR/server/behat
curl -sS https://getcomposer.org/installer | php
php composer.phar install
check_last_command
rm behat.local.yml
cp behat.local.yml.travis behat.local.yml

# -------------------------------------------------- #
# Run tests
# -------------------------------------------------- #
print_message "Run Behat tests."
./bin/behat --tags=~@wip

if [ $? -ne 0 ]; then
  print_error_message "Behat failed."
  exit 1
fi

exit 0
