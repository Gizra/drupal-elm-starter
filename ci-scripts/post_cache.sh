#!/bin/bash
set -euo pipefail

# Load helper functionality.
source helper_functions.sh

# Load various configuration variables.
source "$ROOT_DIR"/server/travis.config.sh

print_message "Post-build cache operations"
date

TRAVIS_CACHE_DIR=/tmp/travis-cache

# Populates cache if needed.
if [[ ! -d "$TRAVIS_CACHE_DIR"/node_modules && -d "$ROOT_DIR"/client/node_modules ]]; then
  echo "Populating NPM cache from client"
  cp -r "$ROOT_DIR"/client/node_modules "$TRAVIS_CACHE_DIR"
fi

if [[ ! -d "$TRAVIS_CACHE_DIR"/www && -d "$ROOT_DIR"/server/www ]]; then
  echo "Populating Drupal cache from server"
  # --no-dereference will cause that we skip Hedley profile entirely.
  cp --no-dereference -r "$ROOT_DIR"/server/www "$TRAVIS_CACHE_DIR"

  # But in Hedley profile, there are files and directories that are
  # dynamic, not stored in the repository, like all the contrib modules.
  mkdir -p "$TRAVIS_CACHE_DIR"/www_ignored
  cd "$ROOT_DIR"
  git ls-files -z --others -i --exclude-standard "$ROOT_DIR"/server/"$PROFILE_NAME" | xargs -I file -0 cp --parents file "$TRAVIS_CACHE_DIR"/www_ignored
fi

date
