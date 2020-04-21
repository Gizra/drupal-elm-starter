#!/bin/bash

################################################################################
#
# Helper functions for the native environment
#
################################################################################

##
# Load the configuration file.
# Will exit with an error message if the configuration file does not exists!
##
function load_config_file {
  # Check if the config file exists.
  if [ ! -f "$ROOT"/config.sh ]; then
    echo
    echo -e  "${BGRED}                                                                 ${RESTORE}"
    echo -e "${BGLRED}  ERROR: No configuration file found!                            ${RESTORE}"
    echo -e  "${BGRED}  > Check if the ${BGLRED}config.sh${BGRED} file exists in the same               ${RESTORE}"
    echo -e  "${BGRED}    directory of the ${BGLRED}install${BGRED} script.                             ${RESTORE}"
    echo -e  "${BGRED}  > If not create one by creating a copy of ${BGLRED}default.config.sh${BGRED}.   ${RESTORE}"
    echo -e  "${BGRED}                                                                 ${RESTORE}"
    echo
    exit 1
  fi

  # Include the configuration file.
  source "$ROOT"/config.sh
}

##
# Installs the site natively.
##
function native_site_install {
  echo -e "${LBLUE}> Starting installation${RESTORE}"
  drush site-install server -y --db-url=mysql://"$MYSQL_USERNAME":"$MYSQL_PASSWORD"@"$MYSQL_HOSTNAME"/"$MYSQL_DB_NAME" --account-pass=admin --existing-config
  drush en server_migrate -y
  drush migrate:import --all
  echo
}

##
# Determines the base URL of the site in the container.
#
##
function get_base_url() {
  echo "$BASE_DOMAIN_URL"
}

##
# Login to Drupal as Administrator using the one time login link.
#
# This command does the login for you when the build script is done.
# It will open a new tab in your default browser and login to your project as
# the Administrator.
##
function drupal_login {
  cd web || exit 1
  BASE_URL="$(get_base_url)"
  URL=$(drush uli --uri "$BASE_URL" --no-browser)
  if ! hash python 2>/dev/null; then
    echo -e "${GREEN} $URL ${RESTORE}"
  else
    python -mwebbrowser "$URL"
  fi
}
