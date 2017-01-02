#!/bin/sh
set -e

# ---------------------------------------------------------------------------- #
#
# Install server dependencies.
#
# ---------------------------------------------------------------------------- #

# Check the current build.
if [ -z ${BUILD_SERVER+x} ] || [ "$BUILD_SERVER" -ne 1 ]; then
 exit 0;
fi


# -------------------------------------------------- #
# Installing Drush.
# -------------------------------------------------- #
cd $TRAVIS_BUILD_DIR
composer global require drush/drush:6.*
phpenv rehash
# Check drush version.
drush --version


# -------------------------------------------------- #
# Installing Behat.
# -------------------------------------------------- #
cd $TRAVIS_BUILD_DIR/server/behat
cp aliases.drushrc.php ~/.drush/
# Copy the travis specific behat config file.
cp behat.local.yml.travis behat.local.yml

# Install the behat dependencies.
composer install


# -------------------------------------------------- #
# Installing Profile.
# -------------------------------------------------- #
cd $TRAVIS_BUILD_DIR/server
cp travis.config.sh config.sh
./install -dy
