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

function get_base_url() {
  ddev describe -j | php -r "\$details = json_decode(file_get_contents('php://stdin')); print_r(\$details->raw->httpurl);"
}

export ROOT_DIR="$TRAVIS_BUILD_DIR"
