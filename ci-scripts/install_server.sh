#!/usr/bin/env bash

# Load helper functionality.
source ci-scripts/helper_functions.sh
# -------------------------------------------------- #
# Move MySQL to RAM.
# -------------------------------------------------- #
print_message "Move MySQL datadir to RAM disk."
sudo service mysql stop
sudo mv /var/lib/mysql /var/run/tmpfs
sudo ln -s /var/run/tmpfs /var/lib/mysql

# -------------------------------------------------- #
# Configure MySQL.
# -------------------------------------------------- #
print_message "Apply sane configuration to MySQL."
sudo cat ci-scripts/mysql.config.ini | tee -a /etc/mysql/my.cnf
sudo service mysql start
check_last_command

# -------------------------------------------------- #
# Installing Drush.
# -------------------------------------------------- #
print_message "Install drush."
export PATH="$HOME/.composer/vendor/bin:$PATH"
# Check drush version.
composer global require drush/drush:8.*
check_last_command
drush --version
cd "$ROOT_DIR" || exit 1
cp ci-scripts/aliases.drushrc.php ~/.drush/

# -------------------------------------------------- #
# Installing Profile.
# -------------------------------------------------- #
print_message "Install Drupal."

source ci-scripts/pre_cache.sh

cd "$ROOT_DIR"/server || exit 1
cp travis.config.sh config.sh
if [[ -d www ]]; then
  bash scripts/reset -dy
else
./install -dy
fi
check_last_command

check_features

# -------------------------------------------------- #
# Starting native webserver via Drush.
# -------------------------------------------------- #
cd "$ROOT_DIR"/server/www || exit 1
drush status || exit 1
drush runserver 127.0.0.1:8080 &
# But wait for the availability of the app.
c=0
until (curl --output /dev/null --silent --head --fail http://127.0.0.1:8080/user/login); do
  ((c++)) && ((c==30)) && exit 1
  sleep 1
done
print_message "The webserver on port 8080 became available"
