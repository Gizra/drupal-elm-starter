#!/usr/bin/env bash

# Load helper functionality.
cd ci-scripts/docker_files

bash preparing_server.sh
bash preparing_client.sh

bash run_behat.sh
bash run_webdriverio.sh
