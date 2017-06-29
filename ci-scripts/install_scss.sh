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

sudo npm install -g stylelint
sudo gem install csscss
