#!/usr/bin/env bash

# Restore to default colours
RESTORE='\033[0m'
# Bold blue color
LBLUE='\033[01;34m'
RED='\033[00;31m'

function print_message() {
  echo
  echo -e "${LBLUE} > $1 ${RESTORE}"
}

function print_error_message() {
  echo
  echo -e "${RED} > $1 ${RESTORE}"
}
# Make sure nothing is wrong with the previous command.
function check_last_command() {
  if [ $? -ne 0 ]; then
    echo
    print_error_message "Something went wrong."
    exit 1
  fi
}

ROOT_DIR="/var/www/html/Server"

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
cp docker_files/default.apache2.conf /etc/apache2/apache2.conf
service apache2 restart
cp docker_files/server.conf /etc/apache2/sites-available/
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
cd $ROOT_DIR
cp docker_files/aliases.drushrc.php ~/.drush/
check_last_command

# -------------------------------------------------- #
# Installing Profile.
# -------------------------------------------------- #
print_message "Install Drupal."
cd $ROOT_DIR/server
cp travis.config.sh config.sh
./install -dy
check_last_command

# -------------------------------------------------- #
# Installing Behat.
# -------------------------------------------------- #
print_message "Install behat."
cd $ROOT_DIR/server/behat
curl -sS https://getcomposer.org/installer | php
php composer.phar install
check_last_command
rm behat.local.yml
cp behat.local.yml.travis behat.local.yml

# -------------------------------------------------- #
# Run tests
# -------------------------------------------------- #
print_message "Run Behat tests."
./bin/behat --tags=~@wip

if [ $? -ne 0 ]; then
  print_error_message "Behat failed."
  exit 1
fi

exit 0
