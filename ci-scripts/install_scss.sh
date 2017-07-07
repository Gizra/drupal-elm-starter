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

npm install -g stylelint@7.12.0
gem install -v 3.4.24 sass
gem install -v 1.3.3 csscss
git clone https://github.com/stylelint/stylelint-config-standard.git

# stylelint is sensitive to have the full path for the base ruleset.
sed -i "s|BASEDIR|$TRAVIS_BUILD_DIR|g" .stylelintrc.json