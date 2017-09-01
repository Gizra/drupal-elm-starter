#!/bin/bash

# ---------------------------------------------------------------------------- #
#
# Run the SCSS reviews.
#
# ---------------------------------------------------------------------------- #

# Check the current build.
if [[ ( -z "${SCSS_REVIEW+x}" || "$SCSS_REVIEW" -ne 1 ) && "$CI" -eq "TRUE" ]]; then
 exit 0;
fi

if [[ "$CI" -eq "TRUE" ]]; then
  source "$TRAVIS_BUILD_DIR"/server/travis.config.sh
else
  DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  source "$DIR"../server/travis.config.sh
fi

HAS_ERRORS=0

SCRIPTS=$(find client/src/assets/scss server/"$PROFILE_NAME"/themes/custom -name '*.scss')
for FILE in $SCRIPTS;  do
  if ! csscss "$FILE"; then
    HAS_ERRORS=1
  fi
  if ! stylelint "$FILE" --formatter verbose; then
    HAS_ERRORS=1
  fi
done

exit $HAS_ERRORS
