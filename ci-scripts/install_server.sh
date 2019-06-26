#!/usr/bin/env bash
set -e

# Load helper functionality.
source ci-scripts/helper_functions.sh

# -------------------------------------------------- #
# Installing ddev dependencies.
# -------------------------------------------------- #
print_message "Install Docker Compose."
sudo rm /usr/local/bin/docker-compose
curl -s -L "https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m)" > docker-compose
chmod +x docker-compose
sudo mv docker-compose /usr/local/bin

print_message "Upgrade Docker."
sudo apt -q update -y
sudo apt -q install --only-upgrade docker-ce -y

# -------------------------------------------------- #
# Installing ddev.
# -------------------------------------------------- #
print_message "Install ddev."
curl -s -L https://raw.githubusercontent.com/drud/ddev/master/scripts/install_ddev.sh | bash

# -------------------------------------------------- #
# Configuring ddev.
# -------------------------------------------------- #
print_message "Configuring ddev."
mkdir ~/.ddev
cp "$ROOT_DIR/ci-scripts/global_config.yaml" ~/.ddev/

# -------------------------------------------------- #
# Installing Profile.
# -------------------------------------------------- #
print_message "Install Drupal."

cd "$ROOT_DIR"/drupal || exit 1
./install -y
check_last_command
./compile-theme
check_last_command
