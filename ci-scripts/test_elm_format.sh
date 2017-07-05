#!/bin/bash

# ---------------------------------------------------------------------------- #
#
# Run the Elm Format reviews.
#
# ---------------------------------------------------------------------------- #

# Check the current build.
if [ -z "${ELM_REVIEW+x}" ] || [ "$ELM_REVIEW" -ne 1 ]; then
 exit 0;
fi

source "$TRAVIS_BUILD_DIR"/server/travis.config.sh

HAS_ERRORS=0

SCRIPTS=$(find client/src -name '*.elm')
for FILE in $SCRIPTS;  do
  echo "Validating $FILE"
  if ! elm-format --validate "$FILE"; then
    HAS_ERRORS=1
  fi
done

exit $HAS_ERRORS
