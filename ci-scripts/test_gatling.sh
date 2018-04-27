#!/usr/bin/env bash

# Load helper functionality.
source ci-scripts/helper_functions.sh

# Check the current build.
if [ -z "${BUILD_GATLING+x}" ] || [ "$BUILD_GATLING" -ne 1 ]; then
 exit 0;
fi

cd "$ROOT_DIR"/server/stress-test
bash run.sh
SERVER_BASE_URL=http://server.local:8080
php acceptance.php gatling-charts-highcharts-bundle-2.3.0/results/server-*/js/global_stats.json
