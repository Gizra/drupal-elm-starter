#!/bin/bash

# Populates cache if needed.

TRAVIS_CACHE_DIR="$TRAVIS_BUILD_DIR"/travis-cache

if [[ ! -d "$TRAVIS_CACHE_DIR"/node_modules ]]; then
  cp -r "$TRAVIS_BUILD_DIR"/client/node_modules "$TRAVIS_CACHE_DIR"
fi

if [[ ! -d "$TRAVIS_CACHE_DIR"/www ]]; then
  # --no-dereference will cause that we skip Hedley profile entirely.
  cp --no-dereference -r "$TRAVIS_BUILD_DIR"/server/www "$TRAVIS_CACHE_DIR"
fi
