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
git clone https://github.com/stylelint/stylelint-config-standard.git

# stylelint is sensitive to have the full path for the base ruleset.
sed -i "s|BASEDIR|$TRAVIS_BUILD_DIR|g" .stylelintrc.json
