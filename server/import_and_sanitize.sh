#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$DIR"/scripts/helper-colors.sh
source "$DIR"/config.sh

if [ "$1" == "-h" ]; then
  echo "Usage: ./$(basename "$0") [Pantheon environment name, live by default]"
  exit 0
fi

# By default, we sync from live, but not neccesarily.
PANTHEON_ENV=${1:-live}
echo -e "Syncing from $PANTHEON_PROJECT_NAME.$PANTHEON_ENV Pantheon environment"

## Check the requirements
if ! hash terminus 2>/dev/null; then
  echo -e "${LYELLOW} Make sure Terminus is available: https://pantheon.io/docs/terminus/install/${RESTORE}"
  exit 2
fi

if ! hash drush 2>/dev/null; then
  echo -e "${LYELLOW} Make sure Drush is available: http://docs.drush.org/en/master/install/${RESTORE}"
  exit 2
fi

cd "$DIR"/www || exit 1
echo -e "${LBLUE} > Purging the old database.${RESTORE}"
drush sql-drop -y

echo -e "${LBLUE} > Fetching and restoring the latest database backup from Pantheon.${RESTORE}"
DB_BACKUP=$(terminus backup:get "$PANTHEON_PROJECT_NAME"."$PANTHEON_ENV" --element=db | head -n1)
curl "$DB_BACKUP" | gunzip | drush sql-cli

cd "$DIR" || exit 1
bash prepare_db_for_dev.sh

echo -e "${LBLUE} > Fetching and restoring the latest files backup from Pantheon.${RESTORE}"
FILES_BACKUP=$(terminus backup:get "$PANTHEON_PROJECT_NAME"."$PANTHEON_ENV" --element=files | head -n1)

if [[ -d "$DIR"/www/sites/default ]]; then
  chmod +w "$DIR"/www/sites/default
  curl "$FILES_BACKUP" | gunzip | tar xf - -C "$DIR"/www/sites/default

  if [[ -d "$DIR"/www/sites/default/files_"$PANTHEON_ENV" ]]; then
    if [[ -d "$DIR"/www/sites/default/files ]]; then
      cp -r "$DIR"/www/sites/default/files/* "$DIR"/www/sites/default/files_"$PANTHEON_ENV"
      rm -rf "$DIR"/www/sites/default/files
    fi
    mv "$DIR"/www/sites/default/files_"$PANTHEON_ENV" "$DIR"/www/sites/default/files
  else
    echo -e "${LRED} # Downloading the backup of the files failed.${RESTORE}"
    exit 1
  fi
fi
