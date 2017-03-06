#!/bin/sh
set -e

# ---------------------------------------------------------------------------- #
#
# Run the Behat/WebDriverIO tests.
#
# ---------------------------------------------------------------------------- #

# Check the current build.
if [ -z ${BUILD_SERVER+x} ] || [ "$BUILD_SERVER" -ne 1 ]; then
 exit 0;
fi

# Set 'BUILD_WEBDRIVERIO' in case it is not defined.
if [ -z ${BUILD_WEBDRIVERIO+x} ]; then
  export BUILD_WEBDRIVERIO=0
fi

cd ci-scripts/docker_files
docker-compose up --abort-on-container-exit
# Docker-compose up won't return with non-zero exit code if one of the
# containers failed, we need to inspect it like this.
# from http://blog.ministryofprogramming.com/docker-compose-and-exit-codes/
docker-compose --file=docker-compose.yml ps -q | xargs docker inspect -f '{{ .State.ExitCode }}' | while read code; do
  if [ "$code" = "1" ]; then
    exit 1
  fi
done
