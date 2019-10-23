#!/usr/bin/env bash
set -e

# Load helper functionality.
source ci-scripts/helper_functions.sh

# -------------------------------------------------- #
# Installing ddev dependencies.
# -------------------------------------------------- #
print_message "Install Docker Compose."
sudo rm /usr/local/bin/docker-compose
curl -s -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" > docker-compose
chmod +x docker-compose
sudo mv docker-compose /usr/local/bin

print_message "Upgrade Docker."
sudo apt-get -y remove docker docker-engine docker.io containerd runc || true
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
# Allow apt update to fail, potentially only some sources are not accessible.
sudo apt -q update -y || true
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

cd "$ROOT_DIR"/server || exit 1
./install -y || ./install -y || ddev logs
check_last_command
