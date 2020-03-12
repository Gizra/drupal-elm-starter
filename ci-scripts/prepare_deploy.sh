#!/bin/bash

set -e

cd "$TRAVIS_BUILD_DIR" || exit 1
source "$TRAVIS_BUILD_DIR/server/scripts/helper-functions.sh"

phpenv config-rm xdebug.ini

# Make Git operations possible.
cp deployment-robot-key ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa

# Make Terminus available.
cd ~ || exit 1
export COMPOSER_MEMORY_LIMIT=-1
curl -s -S -O https://raw.githubusercontent.com/pantheon-systems/terminus-installer/master/builds/installer.phar && php installer.phar install

# Authenticate with Terminus
terminus auth:login --machine-token="$TERMINUS_TOKEN"

cd "$TRAVIS_BUILD_DIR" || exit 1

GIT_HOST="codeserver.dev.abc11525-c334-436c-a62e-5a47febc6c26.drush.in"

ssh-keyscan -p 2222 $GIT_HOST >> ~/.ssh/known_hosts
git clone ssh://codeserver.dev.abc11525-c334-436c-a62e-5a47febc6c26@$GIT_HOST:2222/~/repository.git /tmp/pantheon-drupal-elm-starter

# Refresh configuration
cd /tmp/pantheon-drupal-elm-starter || exit 1
cp "$TRAVIS_BUILD_DIR"/ci-scripts/travis.config.sh config.sh
