#!/usr/bin/env bash

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
  phpcbf --standard=Drupal -p --colors --extensions=php,module,inc,install,test,profile,theme,js,css,info --ignore=$2 $1
  phpcs --standard=Drupal -p --colors --extensions=php,module,inc,install,test,profile,theme,js,css,info --ignore=$2 $1

  phpcbf --standard=DrupalPractice -p --colors --extensions=php,module,inc,install,test,profile,theme,js,css --ignore=$2 $1
  phpcs --standard=DrupalPractice -p --colors --extensions=php,module,inc,install,test,profile,theme,js,css --ignore=$2 $1
  if [ $? -ne 0 ]; then
    HAS_ERRORS=1
  fi
}

# Review custom modules, run each folder separately to avoid memory limits.
PATTERNS="*.features.inc,*.features.*.inc,*.field_group.inc,*.strongarm.inc,*.ds.inc,*.context.inc,*.pages.inc,*.pages_default.inc,*.views_default.inc,*.file_default_displays.inc,*.facetapi_defaults.inc,*.panels_default.inc"

echo
echo "${LBLUE} > Sniffing Modules${RESTORE}"

code_review hedley/modules/custom $PATTERNS

echo
echo $HAS_ERRORS

exit $HAS_ERRORS
