#!/bin/bash

# ---------------------------------------------------------------------------- #
#
# Run the SCSS reviews.
#
# ---------------------------------------------------------------------------- #

# Check the current build.
if [ -z "${SCSS_REVIEW+x}" ] || [ "$SCSS_REVIEW" -ne 1 ]; then
 exit 0;
fi

source "$TRAVIS_BUILD_DIR"/server/travis.config.sh

HAS_ERRORS=0

SCRIPTS=$(find ci-scripts server/"$PROFILE_NAME"/themes/custom -name '*.scss')
for FILE in $SCRIPTS;  do
  if ! csscss "$FILE"; then
    HAS_ERRORS=1
  fi
  if ! stylelint "$FILE"; then
    HAS_ERRORS=1
  fi
done

exit $HAS_ERRORS

