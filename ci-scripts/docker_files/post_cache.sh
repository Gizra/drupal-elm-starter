#!/bin/bash
set -euo pipefail

# Load helper functionality.
source helper_functions.sh

print_message "Post-build cache operations"

# Populates cache if needed.

TRAVIS_CACHE_DIR=/tmp/travis-cache

if [[ ! -d "$TRAVIS_CACHE_DIR"/node_modules && -d "$ROOT_DIR"/client/node_modules ]]; then
  echo "Populating NPM cache from client"
  cp -r "$ROOT_DIR"/client/node_modules "$TRAVIS_CACHE_DIR"
fi

if [[ ! -d "$TRAVIS_CACHE_DIR"/www && -d "$ROOT_DIR"/server/www ]]; then
  echo "Populating Drupal cache from server"
  # --no-dereference will cause that we skip Hedley profile entirely.
  cp --no-dereference -r "$ROOT_DIR"/server/www "$TRAVIS_CACHE_DIR"
fi
