#!/bin/bash
set -e

# ---------------------------------------------------------------------------- #
#
# Install SCSS CI check dependencies.
#
# ---------------------------------------------------------------------------- #

STYLELINT_VERSION="8.1.1"

# Check the current build.
if [[ -z ${CI+x} ]]; then
  echo "Local environment is detected"

  sudo npm install -g stylelint@"$STYLELINT_VERSION"

  DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  ROOT_DIR="$( cd "$( dirname "$DIR" )/" && pwd )"
else
  if [[ -z "${SCSS_REVIEW+x}" || "$SCSS_REVIEW" -ne 1 ]]; then
    exit 0;
  fi

  npm install -g stylelint@"$STYLELINT_VERSION"

  ROOT_DIR="$TRAVIS_BUILD_DIR"
fi

if [ ! -d .stylelint-config-standard ]; then
  cd "$ROOT_DIR"
  git clone https://github.com/stylelint/stylelint-config-standard.git .stylelint-config-standard
  cd .stylelint-config-standard
  npm install
  cd "$ROOT_DIR"
fi

# stylelint is sensitive to have the full path for the base ruleset.
sed -i "s|BASEDIR|$ROOT_DIR|g" .stylelintrc.json.example

cp .stylelintrc.json.example .stylelintrc.json
git checkout .stylelintrc.json.example
