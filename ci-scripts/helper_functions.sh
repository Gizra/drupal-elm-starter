#!/usr/bin/env bash

# Restore to default colours
RESTORE='\033[0m'
# Bold blue color
LBLUE='\033[01;34m'
RED='\033[00;31m'

function print_message() {
  echo
  echo -e "${LBLUE} > $1 ${RESTORE}"
}

function print_error_message() {
  echo
  echo -e "${RED} > $1 ${RESTORE}"
}
# Make sure nothing is wrong with the previous command.
function check_last_command() {
  if [ $? -ne 0 ]; then
    echo
    print_error_message "Something went wrong."
    exit 1
  fi
}

# Make sure Features are in a default state after installation.
function check_features() {
  cd "$TRAVIS_BUILD_DIR"/server/www || exit 1
  if drush features-list --format=csv | grep Overridden ; then
  echo "----"
  print_error_message "The features are overridden, aborting the execution"
    exit 99
  fi
}

export ROOT_DIR="$TRAVIS_BUILD_DIR"
