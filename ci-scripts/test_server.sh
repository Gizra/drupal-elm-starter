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
  if [ ! "$code" = "0" || true ]; then
    sudo apt-get install -y unzip
    cd /tmp
    wget https://github.com/prasmussen/gdrive/files/879060/gdrive-linux-x64.zip
    unzip gdrive-linux-x64.zip
    chmod +x gdrive-linux-x64
    mkdir ~/.gdrive
    cp $TRAVIS_BUILD_DIR/gdrive-service-account.json ~/.gdrive/
    for i in /tmp/videos/*mp4
    do
      ID=$(/tmp/gdrive upload --service-account gdrive-service-account.json $i | tail -n1 | cut -d ' ' -f 2)
      /tmp/gdrive share --service-account gdrive-service-account.json $ÍD
      URL=$(/tmp/gdrive info --service-account gdrive-service-account.json $ÍD  | grep ViewUrl | sed s/ViewUrl\:\ //)
      echo "The video of the failed test case is available from $URL"
      
      # Todo: post to Github issue as a comment
    done;
    exit $code
  fi
done
exit 0
