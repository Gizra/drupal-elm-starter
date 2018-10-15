#!/bin/bash

# Execute full-stack setup in parallel, there's no cross-dependency.

./ci-scripts/install_client.sh &
./ci-scripts/install_server.sh &
./ci-scripts/install_webdriverio.sh &

wait
