#!/usr/bin/env bash

# Load helper functionality.
source helper_functions.sh

# -------------------------------------------------- #
# Start MySQL.
# -------------------------------------------------- #
print_message "Start MySQL."
service mysql start
check_last_command

# -------------------------------------------------- #
# Configure apache2.
# -------------------------------------------------- #
print_message "Configure apache2."
cd "$ROOT_DIR" || exit 1
cp ci-scripts/docker_files/default.apache2.conf /etc/apache2/apache2.conf
service apache2 restart
cp ci-scripts/docker_files/server.conf /etc/apache2/sites-available/
a2ensite server.conf
service apache2 reload
echo "127.0.0.1 server.local" >> /etc/hosts
check_last_command

# -------------------------------------------------- #
# Installing Drush.
# -------------------------------------------------- #
print_message "Install drush."
export PATH="$HOME/.composer/vendor/bin:$PATH"
# Check drush version.
drush --version
cd "$ROOT_DIR" || exit 1
cp ci-scripts/docker_files/aliases.drushrc.php ~/.drush/
check_last_command

# -------------------------------------------------- #
# Installing Profile.
# -------------------------------------------------- #
print_message "Install Drupal."
cd "$ROOT_DIR"/server || exit 1
cp travis.config.sh config.sh
if [[ -d www ]]; then
  bash scripts/reset -dy
else
./install -dy
fi
check_last_command
