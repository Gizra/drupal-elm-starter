#!/bin/sh
set -e

# ---------------------------------------------------------------------------- #
#
# Install SCSS CI check dependencies.
#
# ---------------------------------------------------------------------------- #

# Check the current build.
if [ -z "${SCSS_REVIEW+x}" ] || [ "$SCSS_REVIEW" -ne 1 ]; then
 exit 0;
fi

npm install -g stylelint
gem install sass csscss
git clone git@github.com:stylelint/stylelint-config-standard.git
