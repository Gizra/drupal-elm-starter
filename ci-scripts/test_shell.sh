#!/bin/sh

# ---------------------------------------------------------------------------- #
#
# Run the ShellCheck review.
#
# ---------------------------------------------------------------------------- #

# Check the current build.
if [ -z "${SHELL_REVIEW+x}" ] || [ "$SHELL_REVIEW" -ne 1 ]; then
 exit 0;
fi

HAS_ERRORS=0

code_review () {
  echo "${LWHITE}$1${RESTORE}"
  shellcheck "$1"

  if [ $? -ne 0 ]; then
    HAS_ERRORS=1
  fi
}

SCRIPTS=$(find "$TRAVIS_BUILD_DIR/ci-scripts" "$TRAVIS_BUILD_DIR/server/scripts"  -name '*.sh')
for FILE in $SCRIPTS;  do
  code_review "$FILE"
done

exit $HAS_ERRORS

