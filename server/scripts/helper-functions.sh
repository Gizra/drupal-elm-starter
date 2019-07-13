#!/bin/bash

################################################################################
#
# Helper functions so we can reuse code in different scripts!
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

  # Preserve a few key variables, so they can come from
  # external source like this:
  # export PANTHEON_BRANCH="moo" && ./deploy-do-env.sh
  # Or via another shellscript, see deploy-to-qa.sh
  PROTECTED_VARS=(PANTHEON_BRANCH PANTHEON_ENV MAIN_REPO_BRANCH)
  for VAR in "${PROTECTED_VARS[@]}";
  do
    if [ -n "${!VAR}" ];
    then
      VAR_BACKUP="$VAR"_BACKUP
      export "$VAR_BACKUP=${!VAR}"
    fi
  done

  # Include the configuration file.
  source "$ROOT"/config.sh

  # Restore the key variables.
  for VAR in "${PROTECTED_VARS[@]}";
  do
    VAR_BACKUP="$VAR"_BACKUP
    if [ -n "${!VAR_BACKUP}" ];
    then
      export "$VAR=${!VAR_BACKUP}"
    fi
  done
}


##
# Cleanup the sites/default/ directory:
# - Removes the files directory.
# - Removes the settings.php file.
#
# Uses (requests) sudo powers if needed!
##
function delete_sites_default_content {
  # Cleanup the web/sites/default content.
  if [ -d "$ROOT"/web/sites ]; then
    echo -e "${LBLUE}> Cleaning up the sites/default directory${RESTORE}"
    chmod 777 "$ROOT"/web/sites/default
    rm -rf "$ROOT"/web/sites/default/files
    echo
  fi

  # Backup in case of we need sudo powers to get rid of the files directory.
  if [ -d "$ROOT"/web/sites/default/files ]; then
    echo -e "${LBLUE}> Cleaning up the sites/default/files directory with sudo power!${RESTORE}"
    sudo rm -rf "$ROOT"/web/sites/default/files
    echo
  fi
}

##
# Cleanup the settings
#
# Uses (requests) sudo powers if needed!
##
function delete_settings {
  if [ -d "$ROOT"/web/sites ]; then
    chmod 777 "$ROOT"/web/sites/default
    rm -f "$ROOT"/web/sites/default/settings.php
    # Backup in case of we need sudo powers to get rid of the settings.php directory.
    if [ -f "$ROOT"/web/sites/default/settings.php ]; then
      echo -e "${LBLUE}> Cleaning up the sites/default/settings.php file with sudo power!${RESTORE}"
      sudo rm -rf "$ROOT"/web/sites/default/settings.php
      echo
    fi
  fi
}

##
# Cleanup the profile/ directory:
# - Remove contributed modules (modules/contrib).
# - Remove development modules (modules/development).
# - Remove contributed themes (themes/contrib).
# - Remove libraries (libraries).
##
function delete_profile_contrib {
  # Cleanup the contrib modules
  if [ -d "$ROOT/web/modules/contrib/" ]; then
    echo -e "${LBLUE}> Cleaning up the $ROOT/web/modules/contrib directory${RESTORE}"
    rm -rf "$ROOT/web/modules/development"
    echo
  fi

  # Cleanup the contrib themes
  if [ -d "$ROOT/web/themes/contrib" ]; then
    echo -e "${LBLUE}> Cleaning up the $PROFILE_NAME/themes/contrib directory${RESTORE}"
    rm -rf "$ROOT/web/themes/contrib"
    echo
  fi

  # Cleanup the profiles folder
  if [ -d "$ROOT/web/profiles/contrib" ]; then
    echo -e "${LBLUE}> Cleaning up the $ROOT/web/profiles/contrib directory${RESTORE}"
    rm -rf "$ROOT/web/profiles/contrib"
    echo
  fi

  # Cleanup the core folder
  if [ -d "$ROOT/web/core" ]; then
    echo -e "${LBLUE}> Cleaning up the $ROOT/web/core directory${RESTORE}"
    rm -rf "$ROOT/web/core"
    echo
  fi

}

##
# Composer install.
##
function composer_install {
  echo -e "${LBLUE}> Composer install${RESTORE}"

  cd "$ROOT"
  COMPOSER_MEMORY_LIMIT=-1 composer install
  echo
}

##
# Create (if not exists) and set the proper file permissions
# on the sites/default/files directory.
##
function create_sites_default_files_directory {
  if [ ! -d "$ROOT"/web/sites/default/files ]; then
    echo -e "${LBLUE}> Create the files directory (sites/default/files directory)${RESTORE}"
    mkdir -p "$ROOT"/web/sites/default/files
  fi

  echo -e "${LBLUE}> Set the file permissions on the sites/default/files directory${RESTORE}"
  chmod -R 777 "$ROOT"/web/sites/default/files
  umask 000 "$ROOT"/web/sites/default/files
  chmod -R g+s "$ROOT"/web/sites/default/files
  echo
}


##
# Enable the development modules.
##
function enable_development_modules {
  echo -e "${LBLUE}> Enabling the development modules${RESTORE}"
  cd "$ROOT"/web
  ddev exec drush pm-enable -y devel
  cd "$ROOT"
  echo
}

##
# Start containers for the local development.
##
function start_ddev {
  echo -e "${LBLUE}> Starting local development environment${RESTORE}"
  cd "$ROOT"
  if [[ -f .ddev/docker-compose.yaml ]]; then
    ddev remove || true
  fi
  ddev config global --instrumentation-opt-in=false
  ddev start || exit 1
  cd "$ROOT"
  echo -e "${LBLUE}> The local site instance configuration is ready${RESTORE}"
  echo
}

##
# Update settings.php.
#
# Various settings.php customization.
##
function update_settings {
  echo -e "${LBLUE}> Updating settings${RESTORE}"
  SETTINGS="$ROOT/web/sites/default/settings.php"
  chmod 777 "$SETTINGS"

  {
    echo ""
    echo "/**"
    echo " * Config Sync settings."
    echo " */"
    echo "\$config_directories[CONFIG_SYNC_DIRECTORY] = '../config/sync';"
  } >> "$SETTINGS"

  # Protect the settings from changes, to prevent drupal's warning.
  chmod 755 "$SETTINGS"
}


##
# Fill string with spaces until required length.
#
# @param string The string.
# @param int The requested total length.
##
function fill_string_spaces {
  STRING="$1"
  STRING_LENGTH=${#STRING}
  DESIRED_LENGTH="$2"
  SPACES_LENGTH=$((DESIRED_LENGTH-STRING_LENGTH))

  if [[ 0 -gt "$SPACES_LENGTH" ]]; then
    SPACES_LENGTH=0
  fi

  printf -v SPACES '%*s' $SPACES_LENGTH
  echo "$STRING$SPACES"
}

##
# Determines the base URL of the site in the container.
#
##
function get_base_url() {
  ddev describe -j | php -r "\$details = json_decode(file_get_contents('php://stdin')); print_r(\$details->raw->urls[0]);"
}

##
# Login to Drupal as Administrator using the one time login link.
#
# This command does the login for you when the build script is done.
# It will open a new tab in your default browser and login to your project as
# the Administrator.
##
function drupal_login {
  cd web
  BASE_URL="$(get_base_url)"
  URL=$(ddev exec drush uli --uri "$BASE_URL")
  if ! hash python 2>/dev/null; then
    echo -e "${GREEN} $URL ${RESTORE}"
  else
    python -mwebbrowser "$URL"
  fi
}

##
# Check if there is a post script and run it.
#
# @param string $1
#   The kind of post script to run.
##
function run_post_script {
  echo -e "${LBLUE}> Post-install hooks${RESTORE}"
  if [ ! "$1" ]; then
    return 1
  fi

  # Define post script name.
  POST_FUNCT_NAME="post_$1"

  # Check if the function is declared.
  declare -Ff "$POST_FUNCT_NAME" >/dev/null;
  if [ $? -eq 1 ]; then
    return 1
  fi

  # Run the post script.
  echo -e "${LBLUE}> Run $POST_FUNCT_NAME script.${RESTORE}"
  $POST_FUNCT_NAME
  echo
}
