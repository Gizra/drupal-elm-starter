#!/usr/bin/env bash

# Load helper functionality.
source helper_functions.sh

bash preparing_server.sh
bash preparing_client.sh

bash run_behat.sh
bash run_webdriverio.sh
