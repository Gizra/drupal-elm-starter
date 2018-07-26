#!/bin/bash

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ ! -d "$BASE_DIR"/gatling-charts-highcharts-bundle-2.3.0 ]; then
  cd "$BASE_DIR" || exit 1
  wget https://repo1.maven.org/maven2/io/gatling/highcharts/gatling-charts-highcharts-bundle/2.3.0/gatling-charts-highcharts-bundle-2.3.0-bundle.zip
  unzip gatling-charts-highcharts-bundle-2.3.0-bundle.zip
  rm gatling-charts-highcharts-bundle-2.3.0-bundle.zip
  cd gatling-charts-highcharts-bundle-2.3.0 || exit 1
  ln -s "$BASE_DIR"/Server.scala user-files/simulations/
fi
cd "$BASE_DIR"/gatling-charts-highcharts-bundle-2.3.0 || exit 1
./bin/gatling.sh -s Server
