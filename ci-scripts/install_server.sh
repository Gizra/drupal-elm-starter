#!/usr/bin/env bash

# Check the current build.
if [ -z "${BUILD_SERVER+x}" ] || [ "$BUILD_SERVER" -ne 1 ]; then
 exit 0;
fi

# Load helper functionality.
source ci-scripts/helper_functions.sh

# -------------------------------------------------- #
# Start MySQL.
# -------------------------------------------------- #
print_message "Start MySQL."
service mysql start
check_last_command

# -------------------------------------------------- #
# Installing Drush.
# -------------------------------------------------- #
print_message "Install drush."
export PATH="$HOME/.composer/vendor/bin:$PATH"
# Check drush version.
composer global require drush/drush:8.*
drush --version
cd "$ROOT_DIR" || exit 1
mkdir ~/.drush/
cp ci-scripts/aliases.drushrc.php ~/.drush/
check_last_command

# -------------------------------------------------- #
# Installing Profile.
# -------------------------------------------------- #
print_message "Install Drupal."

source pre_cache.sh

cd "$ROOT_DIR"/server || exit 1
cp travis.config.sh config.sh
if [[ -d www ]]; then
  bash scripts/reset -dy
else
./install -dy
fi
check_last_command

# -------------------------------------------------- #
# Starting native webserver via Drush.
# -------------------------------------------------- #
drush runserver 127.0.0.1:8080 &
until netstat -an 2>/dev/null | grep '8080.*LISTEN'; do true; done
