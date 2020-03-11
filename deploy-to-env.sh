#!/bin/bash

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$ROOT"

# Load the colors.
# shellcheck source=scripts/helper-colors.sh
if [[ -f  "$ROOT"/scripts/helper-colors.sh ]];
then
  source "$ROOT"/scripts/helper-colors.sh
else
  source "$ROOT"/server/scripts/helper-colors.sh
fi

# Load the helpers.
# shellcheck source=scripts/helper-functions.sh
if [[ -f  "$ROOT"/scripts/helper-functions.sh ]];
then
  source "$ROOT"/scripts/helper-functions.sh
else
  source "$ROOT"/server/scripts/helper-functions.sh
fi
source "$ROOT"/ci-scripts/helper-functions.sh

##
# Prints a message and ends the program.
#
# @param string $1
#   The message to show before exit the program.
##
function exit_msg() {
  echo
  echo -e "${RED} > $1 ${RESTORE}"
  exit
}

# Load the configuration.
load_config_file

##
# Function to run the actual deploy to Pantheon.
##
function deploy() {
  sanityChecks
  if [[ -z "$CI" ]];
  then
    requireDeploymentApproval
  fi
  COMMIT_RESULT=$(commitAndPushChanges)

  doFreshInstall
  syncConfigs
}

##
# Checks that all the required commands to run the deployement are available.
##
function sanityChecks() {
  # Make sure you are not using a `alias cp = cp -i` alias in your system.
  unalias cp 2> /dev/null || true

  terminus --version 1> /dev/null 2> /dev/null || exit_msg "terminus not found."
  git --version 1> /dev/null 2> /dev/null || exit_msg "git not found."
  tar --version 1> /dev/null 2> /dev/null || exit_msg "tar not found."
  make --version 1> /dev/null 2> /dev/null || exit_msg "make not found."
  grep --version 1> /dev/null 2> /dev/null || exit_msg "grep not found."

  CURRENT_BRANCH=$(git branch | grep \* | cut -c3-)
  if [ "$CURRENT_BRANCH" != "$PANTHEON_BRANCH" ] ; then
    exit_msg "You are in $CURRENT_BRANCH but you need to be in $PANTHEON_BRANCH branch to deploy."
  fi

  CHECK_REMOTE_REPO=$(git remote -v | grep drush.in)
  if [ "$CHECK_REMOTE_REPO" == "" ] ; then
    echo "Remotes configured for this repository are not pointing to Pantheon."
    git remote -v
    exit_msg "Please run the deploy inside directory that points to pantheon-repo."
  fi

  if [ -z ${PANTHEON_BRANCH+x} ]; then exit_msg "Please set a value for PANTHEON_BRANCH in config.sh"; fi
  if [ -z ${PANTHEON_SITE+x} ]; then exit_msg "Please set a value for PANTHEON_SITE in config.sh"; fi
  if [ -z ${PANTHEON_ENV+x} ]; then exit_msg "Please set a value for PANTHEON_ENV in config.sh"; fi
  if [ -z ${WIPE_ENV+x} ]; then exit_msg "Please set a value for WIPE_ENV in config.sh"; fi
  if [ -z ${CREATE_DEFAULT_CONTENT+x} ]; then exit_msg "Please set a value for CREATE_DEFAULT_CONTENT in config.sh"; fi
  if [ -z ${MAIN_REPO+x} ]; then exit_msg "Please set a value for MAIN_REPO in config.sh"; fi
  if [ -z ${MAIN_REPO_BRANCH+x} ]; then exit_msg "Please set a value for MAIN_REPO_BRANCH in config.sh"; fi
}

##
# Ask for confirmation approval to run the deploy.
##
function requireDeploymentApproval() {
  print_error_message "Warning! This is going to run a deployment in $PANTHEON_SITE.$PANTHEON_ENV"
  if [ -z ${DEPLOY_TAG+x} ];
  then
    print_error_message "Github '$MAIN_REPO_BRANCH' branch will be deployed on '$PANTHEON_BRANCH' Pantheon branch."
  else
    print_error_message "Release $DEPLOY_TAG will be deployed on $PANTHEON_BRANCH Pantheon branch."
    print_error_message "Make sure there is a $DEPLOY_TAG tag in the github repository."
  fi
  if [ "$WIPE_ENV" = true ] ; then
    print_error_message "All the site information will be deleted!!"
  fi

  print_error_message "Database and Files will be cloned from LIVE into DEV."

  if [ "$CREATE_DEFAULT_CONTENT" = true ] ; then
    print_error_message "Default content will be created in the site."
  else
    print_message "No content will be created in the site."
  fi

  echo -e -n "${LRED}Are you sure?${RESTORE} (Y/n) "
  read -e -n 1 -r
  if [[ ! $REPLY =~ ^[Y|y]$ ]]; then
    echo
    echo -e  "${BGYELLOW}                                                                 ${RESTORE}"
    echo -e "${BGLYELLOW}  Deployment aborted!                                            ${RESTORE}"
    echo -e  "${BGYELLOW}                                                                 ${RESTORE}"
    echo
    exit 0
  fi
}

##
# Clones the origin repository into github-repo folder.
##
function cloneRepo() {
  echo "Resetting pantheon-repo to $PANTHEON_BRANCH branch..."
  cd /tmp/pantheon-drupal-elm-starter
  git clean -f -d .
  git fetch
  git reset --hard origin/"$PANTHEON_BRANCH"
  git checkout -B "$PANTHEON_BRANCH"

  cd github-repo
    if [ -z ${DEPLOY_TAG+x} ];
    then
      git fetch origin "$MAIN_REPO_BRANCH"
      git reset --hard origin/"$MAIN_REPO_BRANCH"
    else
      git fetch origin "$DEPLOY_TAG"
      git reset --hard origin/"$DEPLOY_TAG"
    fi
    if [[ -n $(git status -s) ]]; then
      git status
      echo -e -n "${RED} > The GitHub repository is still dirty, giving up"
      cd "$ROOT"
      exit 1
    fi
    cd "$ROOT"
  fi
}

##
# Copies the data from the repository into the Pantheon repo and commit the
# changes.
##
function commitAndPushChanges() {
  rm -fR config/sync || true
  rm -fR web/profiles || true
  rm -fR web/modules || true
  rm -fR web/themes || true
  cp -fR github-repo/server/* .
  cp -fR github-repo/deploy-* .

  cd "$ROOT" || exit
  # Get the last date and commit has of the commit that is going to be deployed.
  LAST_COMMIT_DATE=$(git log -1 --format=%cd)
  LAST_COMMIT_HASH=$(git log -1 --format=%h)
  cd ..

  updateDependencies
  compileTheme
  cleanGit

  # If there's nothing to commit, let's abort the process.
  # It's still successful, it can be fine for non-Drupal related
  # PRs.
  if [[ $(git add . --dry-run | wc -l) -eq 0 ]]; then
    echo "nothing to commit"
  fi

  git add --all .
  if [ -z ${DEPLOY_TAG+x} ];
  then
    git commit -m "Synced with $MAIN_REPO_BRANCH: $LAST_COMMIT_DATE - $LAST_COMMIT_HASH"
  else
    git commit -m "Deployed release $DEPLOY_TAG: $LAST_COMMIT_DATE - $LAST_COMMIT_HASH"
  fi
  git push origin "$PANTHEON_BRANCH"
  return 0
}

##
# Run composer install.
##
function updateDependencies() {
  if ! composer install;
  then
    echo "Deleting vendor, attempting to execute 'composer install' again..."
    # @see https://stackoverflow.com/a/21014401
    rm -rf vendor
    composer install
  fi
}

##
# In the current directory, strips the .git modules in subfolders.
##
function cleanGit() {
  (find -path ./github-repo -prune -o -print | grep "\.git" | grep -v "^./.git"  |  xargs rm -rf) || true
}

##
# Deletes the files and databases of the environment.
##
function wipeEnvironment() {
  terminus env:wipe "$PANTHEON_SITE.$PANTHEON_ENV" -y
}

##
# Restore the initial database dump into an empty Pantheon database.
##
function doFreshInstall() {
  echo "Fresh install..."
  terminus remote:drush "$PANTHEON_SITE.$PANTHEON_ENV" -- site-install server -y --existing-config

  echo "Migrations..."
  terminus remote:drush "$PANTHEON_SITE.$PANTHEON_ENV" -- en server_migrate -y
  terminus remote:drush "$PANTHEON_SITE.$PANTHEON_ENV" -- migrate:import --group=server

  echo "Search API reindex..."
  terminus remote:drush "$PANTHEON_SITE.$PANTHEON_ENV" -- sapi-c
  terminus remote:drush "$PANTHEON_SITE.$PANTHEON_ENV" -- sapi-i
}

##
# Syncronize configurations and run database updates.
##
function syncConfigs() {
  terminus remote:drush "$PANTHEON_SITE.$PANTHEON_ENV" -- cr
  terminus remote:drush "$PANTHEON_SITE.$PANTHEON_ENV" -- updb -y
  terminus remote:drush "$PANTHEON_SITE.$PANTHEON_ENV" -- cim -y
  terminus remote:drush "$PANTHEON_SITE.$PANTHEON_ENV" -- entup -y
}

deploy
