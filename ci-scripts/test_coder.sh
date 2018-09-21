#!/bin/sh

# ---------------------------------------------------------------------------- #
#
# Run the coder review.
#
# ---------------------------------------------------------------------------- #

HAS_ERRORS=0

##
# Function to run the actual code review
#
# This function takes 2 params:
# @param string $1
#   The file path to the directory or file to check.
# @param string $2
#   The ignore pattern(s).
##
code_review () {
  echo "${LWHITE}$1${RESTORE}"

  if ! phpcs --standard="$REVIEW_STANDARD" -p --colors --extensions=php,module,inc,install,test,profile,theme,js,css --ignore="$2" "$1"; then
    HAS_ERRORS=1
  fi
}

# Review custom modules, run each folder separately to avoid memory limits.
IGNORED_PATTERNS="*.features.inc,*.features.*.inc,*.field_group.inc,*.strongarm.inc,*.ds.inc,*.context.inc,*.pages.inc,*.pages_default.inc,*.views_default.inc,*.file_default_displays.inc,*.facetapi_defaults.inc,*.panels_default.inc"

echo
echo "${LBLUE}> Sniffing Modules following '${REVIEW_STANDARD}' standard. ${RESTORE}"

for dir in $TRAVIS_BUILD_DIR/server/hedley/modules/custom/*/ ; do
  code_review "$dir" "$IGNORED_PATTERNS"
done

exit $HAS_ERRORS
