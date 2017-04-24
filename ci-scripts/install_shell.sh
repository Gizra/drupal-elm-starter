#!/bin/sh
set -e

# ---------------------------------------------------------------------------- #
#
# Install Shell scripting CI check dependencies.
#
# ---------------------------------------------------------------------------- #

# Check the current build.
if [ -z "${SHELL_REVIEW+x}" ] || [ "$SHELL_REVIEW" -ne 1 ]; then
 exit 0;
fi

sudo apt-get -qq update
sudo apt-get -qq install shellcheck
