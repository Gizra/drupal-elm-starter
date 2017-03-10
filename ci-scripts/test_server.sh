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

# Simple Docker run to execute Behat.
if [ -z ${BUILD_WEBDRIVERIO+x} ]; then
  docker run -it -e "BUILD_WEBDRIVERIO=0" -p 8080:80 server
  exit $?
fi

# Execute our server container alongside with Selenium container for WDIO.
cd ci-scripts/docker_files
docker-compose up --abort-on-container-exit
# Docker-compose up won't return with non-zero exit code if one of the
# containers failed, we need to inspect it like this.
# from http://blog.ministryofprogramming.com/docker-compose-and-exit-codes/
docker-compose --file=docker-compose.yml ps -q | xargs docker inspect -f '{{ .State.ExitCode }}' | while read code; do
  if [ ! "$code" = "0" ]; then
    exit $code
  fi
done
exit 0
