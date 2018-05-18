#!/usr/bin/env bash

# Check the current build.
if [ -z "${BUILD_SERVER+x}" ] || [ "$BUILD_SERVER" -ne 1 ]; then
 exit 0;
fi

# Load helper functionality.
source ci-scripts/helper_functions.sh
# -------------------------------------------------- #
# Move MySQL to RAM.
# -------------------------------------------------- #
print_message "Move MySQL datadir to RAM disk."
sudo service mysql stop
sudo mv /var/lib/mysql /var/run/tmpfs
sudo ln -s /var/run/tmpfs /var/lib/mysql
sudo service mysql start

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
drush runserver 127.0.0.1:8080 &
until netstat -an 2>/dev/null | grep '8080.*LISTEN'; do true; done

wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip
unzip ngrok-stable-linux-amd64.zip
./ngrok http 8080 --log stdout --log-level debug
