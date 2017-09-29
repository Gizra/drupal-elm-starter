#!/bin/sh
set -e

# ---------------------------------------------------------------------------- #
#
# Install elm-analyse.
#
# ---------------------------------------------------------------------------- #

# Check the current build.
if [ -z "${ELM_REVIEW+x}" ] || [ "$ELM_REVIEW" -ne 1 ]; then
 exit 0;
fi

npm install -g elm-format@0.6.1-alpha
npm install -g elm-analyse@0.11.0
