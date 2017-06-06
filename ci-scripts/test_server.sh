#!/bin/bash
set -euo pipefail

# ---------------------------------------------------------------------------- #
#
# Run the Behat/WebDriverIO tests.
#
# ---------------------------------------------------------------------------- #

# Check the current build.
if [ -z "${BUILD_SERVER+x}" ] || [ "$BUILD_SERVER" -ne 1 ]; then
 exit 0;
fi

# Simple Docker run to execute Behat.
if [ -z "${BUILD_WEBDRIVERIO+x}" ]; then
  mkdir -p "$TRAVIS_BUILD_DIR"/travis-cache
  docker run -v "$TRAVIS_BUILD_DIR"/travis-cache:/tmp/travis-cache -it -e "BUILD_WEBDRIVERIO=0" -p 8080:80 server
  exit $?
fi

VIDEO_DIR=/tmp/videos

# Execute our server container alongside with Selenium container for WDIO.
mkdir -p "$VIDEO_DIR"
cd ci-scripts/docker_files

! docker-compose up --abort-on-container-exit

# Docker-compose up won't return with non-zero exit code if one of the
# containers failed, we need to inspect it like this.
# from http://blog.ministryofprogramming.com/docker-compose-and-exit-codes/
docker-compose --file=docker-compose.yml ps -q server.local | xargs docker inspect -f '{{ .State.ExitCode }}' | while read -r code; do
  if [ ! "$code" = "0" ]; then
    source "$TRAVIS_BUILD_DIR"/server/travis.config.sh
    sudo chmod -R 777 /tmp/test_results

    echo "One of the containers exited with $code"
    VID_COUNT=$(find "$VIDEO_DIR" -type f -name '*mp4'  -printf '.' | wc -c)
    echo "Detected $VID_COUNT videos"
    if [[ $VID_COUNT -eq 0 ]]; then
      echo "No videos, skipping upload"
      exit "$code"
    fi
    cd /tmp
    ! rm gdrive-linux-x64.zip
    wget https://github.com/prasmussen/gdrive/files/879060/gdrive-linux-x64.zip
    unzip gdrive-linux-x64.zip
    chmod +x ./gdrive
    mkdir ~/.gdrive
    cp "$TRAVIS_BUILD_DIR"/gdrive-service-account.json ~/.gdrive/
    GH_COMMENT=/tmp/video_urls
    echo -n '{
  "body": "' >> $GH_COMMENT
    for VIDEO_FILE in $VIDEO_DIR/*mp4
    do
      # Test if the spec is a failing one or not.
      UPLOAD=0
      cp /tmp/test_results/failed_tests /tmp/test_results/failed_tests.tmp
      while IFS= read -r FAILED_SPEC
      do
        if [[ $VIDEO_FILE == *"$FAILED_SPEC"* ]]; then
          UPLOAD=1
          # Uploading one video per failed spec. Assuming that it failed
          # 3 times, it failed always the same way, removing the line from
          # the file, so next time, it won't match.
          sed -i "/$FAILED_SPEC/d" /tmp/test_results/failed_tests
          break
        fi
      done < /tmp/test_results/failed_tests.tmp

      if [[ $UPLOAD -eq 0 ]]; then
        echo "$VIDEO_FILE contains a passed test, skipping"
        continue
      fi

      echo "Uploading $VIDEO_FILE, it contains a failed test"
      ID=$(/tmp/gdrive upload --service-account gdrive-service-account.json "$VIDEO_FILE" | tail -n1 | cut -d ' ' -f 2)
      /tmp/gdrive share --service-account gdrive-service-account.json "$ID"
      URL=$(/tmp/gdrive info --service-account gdrive-service-account.json "$ID" | grep ViewUrl | sed s/ViewUrl:\ //)
      echo -n "* Video of the failed WebdriverIO test [$FAILED_SPEC]($URL)." | tee -a $GH_COMMENT
      echo ""
      printf '\\n' >> $GH_COMMENT

    done;
    echo '"}' >> $GH_COMMENT

    # Todo: make it non-Gizra specific by detecting the user of the repository.
    PR_URL=$(curl -H "Authorization: token $GH_TOKEN" -s  https://api.github.com/repos/"$GH_REPO"/pulls?head=Gizra:"${TRAVIS_PULL_REQUEST_BRANCH:-$TRAVIS_BRANCH}" | grep '"url"' | head -n1  | cut -d'"' -f 4)
    PR_URL=${PR_URL/\/pulls\//\/issues\/}
    if [[ -z "${PR_URL// }" ]]; then
      echo "Failed to detect related GitHub issue"
    else
      echo "Detected issue: $PR_URL. Posting GitHub comment..."
      ! curl -H "Authorization: token $GH_TOKEN" --data @$GH_COMMENT "$PR_URL"/comments
    fi
    exit "$code"
  fi
done

exit 0
