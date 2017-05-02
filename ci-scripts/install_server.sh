#!/bin/sh
set -e

# ---------------------------------------------------------------------------- #
#
# Install server dependencies.
#
# ---------------------------------------------------------------------------- #

# Check the current build.
if [ -z "${BUILD_SERVER+x}" ] || [ "$BUILD_SERVER" -ne 1 ]; then
 exit 0;
fi

# Build our own Docker image based on https://github.com/Gizra/drupal-lamp.
docker build -t server -f "$TRAVIS_BUILD_DIR"/ci-scripts/docker_files/Dockerfile .

# Simple Docker run, no need for Zalenium dependencies.
if [ -z "${BUILD_WEBDRIVERIO+x}" ]; then
  exit 0;
fi

# Zalenium requires to download this dependency image first.
docker pull elgalu/selenium
