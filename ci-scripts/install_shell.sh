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

docker pull koalaman/shellcheck:v0.4.6
