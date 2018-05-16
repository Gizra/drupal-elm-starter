#!/usr/bin/env bash

# Load helper functionality.
source ci-scripts/helper_functions.sh

# Check the current build.
if [ -z "${BUILD_GATLING+x}" ] || [ "$BUILD_GATLING" -ne 1 ]; then
 exit 0;
fi

cd "$ROOT_DIR"/server/stress-test || exit 1
export SERVER_BASE_URL=http://server.local:8080
bash run.sh
php acceptance.php gatling-charts-highcharts-bundle-2.3.0/results/server-*/js/global_stats.json
wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip
unzip ngrok-stable-linux-amd64.zip
./ngrok http 8080  --log stdout --log-level debug &
for i in `seq 600`; do
  sleep 10
  echo "."
done;
