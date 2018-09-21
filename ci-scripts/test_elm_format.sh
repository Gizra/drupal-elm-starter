#!/bin/bash

# ---------------------------------------------------------------------------- #
#
# Run the Elm Format reviews.
#
# ---------------------------------------------------------------------------- #

source "$TRAVIS_BUILD_DIR"/server/travis.config.sh

HAS_ERRORS=0

SCRIPTS=$(find client/src -name '*.elm')
for FILE in $SCRIPTS;  do
  echo "Validating $FILE"
  if ! elm-format --elm-version=0.18 --validate "$FILE"; then
    HAS_ERRORS=1
  fi
done

exit $HAS_ERRORS
