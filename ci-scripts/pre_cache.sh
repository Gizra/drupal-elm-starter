#!/bin/bash
set -euo pipefail

# Load helper functionality.
source helper_functions.sh

# Load various configuration variables.
source "$ROOT_DIR"/server/travis.config.sh

print_message "Pre-build cache operations"
date
# Uses the cached objects from Travis cache or invalidate

TRAVIS_CACHE_DIR=/tmp/travis-cache
NPM_HASH_FILE="$TRAVIS_CACHE_DIR"/.npm.sum
DRUPAL_HASH_FILE="$TRAVIS_CACHE_DIR"/.drupal.sum

if [[ -f "$NPM_HASH_FILE" ]]; then
  PREVIOUS_NPM_HASH=$(<"$NPM_HASH_FILE")
else
  PREVIOUS_NPM_HASH=""
fi

if [[ -f "$DRUPAL_HASH_FILE" ]]; then
  PREVIOUS_DRUPAL_HASH=$(<"$DRUPAL_HASH_FILE")
else
  PREVIOUS_DRUPAL_HASH=""
fi

CURRENT_DRUPAL_HASH=$(cat "$ROOT_DIR"/server/"$PROFILE_NAME"/drupal-org.make "$ROOT_DIR"/server/"$PROFILE_NAME"/drupal-org-core.make | sha256sum  | cut -f1 -d ' ')
CURRENT_NPM_HASH=$(sha256sum < "$ROOT_DIR"/client/package.json | cut -f1 -d ' ')

echo "$CURRENT_DRUPAL_HASH" > "$DRUPAL_HASH_FILE"
echo "$CURRENT_NPM_HASH" > "$NPM_HASH_FILE"

if [[ "$PREVIOUS_NPM_HASH" == "$CURRENT_NPM_HASH" && -d "$TRAVIS_CACHE_DIR"/node_modules ]]; then
  echo "NPM build hash matches, copying node_modules ($PREVIOUS_NPM_HASH == $CURRENT_NPM_HASH)"
  cp -r "$TRAVIS_CACHE_DIR"/node_modules "$ROOT_DIR"/client
else
  echo "NPM build hash does not match, purging cache ($PREVIOUS_NPM_HASH <> $CURRENT_NPM_HASH)"
  rm -rf "$TRAVIS_CACHE_DIR"/node_modules
fi

if [[ "$PREVIOUS_DRUPAL_HASH" == "$CURRENT_DRUPAL_HASH" && -d "$TRAVIS_CACHE_DIR"/www ]]; then
  echo "Drupal build hash matches, copying www ($PREVIOUS_DRUPAL_HASH == $CURRENT_DRUPAL_HASH)"
  cp -r "$TRAVIS_CACHE_DIR"/www "$ROOT_DIR"/server
  cp -r "$TRAVIS_CACHE_DIR"/www_ignored/* "$ROOT_DIR"/
else
  echo "Drupal build hash does not match, purging cache ($PREVIOUS_DRUPAL_HASH <> $CURRENT_DRUPAL_HASH)"
  rm -rf "$TRAVIS_CACHE_DIR"/www
fi
date
