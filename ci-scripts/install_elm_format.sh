#!/bin/sh
set -e

# ---------------------------------------------------------------------------- #
#
# Install Elm Format.
#
# ---------------------------------------------------------------------------- #

# Check the current build.
if [ -z "${ELM_REVIEW+x}" ] || [ "$ELM_REVIEW" -ne 1 ]; then
 exit 0;
fi

npm install -g elm-format@exp
