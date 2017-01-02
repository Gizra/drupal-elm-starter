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
# Install Firefox (iceweasel).
# -------------------------------------------------- #
print_message "Install firefox."
apt-get update
apt-get -qq -y install iceweasel > /dev/null
check_last_command

# -------------------------------------------------- #
# Install headless GUI for browser.'Xvfb is a display server that performs graphical operations in memory'
# -------------------------------------------------- #
print_message "Installing XVFB (headless GUI for Firefox)."
apt-get install xvfb -y
apt-get install openjdk-7-jre-headless -y
Xvfb :99 -ac &
check_last_command
export DISPLAY=:99
sleep 5

# -------------------------------------------------- #
# Install Selenium.
# -------------------------------------------------- #
print_message  "Install Selenium."
wget http://selenium-release.storage.googleapis.com/2.53/selenium-server-standalone-2.53.0.jar
java -jar selenium-server-standalone-2.53.0.jar > /dev/null 2>&1 &
check_last_command
sleep 10

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
