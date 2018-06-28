#!/usr/bin/env bash

# Load helper functionality.
source ci-scripts/helper_functions.sh

# Check the current build.
if [ -z "${BUILD_GATLING+x}" ] || [ "$BUILD_GATLING" -ne 1 ]; then
 exit 0;
fi

cd "$ROOT_DIR"/server/stress-test || exit 1
export SERVER_BASE_URL=http://127.0.0.1:8080
bash run.sh
php acceptance.php gatling-charts-highcharts-bundle-2.3.0/results/server-*/js/global_stats.json
