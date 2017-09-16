#!/bin/bash

# ---------------------------------------------------------------------------- #
#
# Run the elm-analyse reviews.
#
# ---------------------------------------------------------------------------- #

# Check the current build.
if [ -z "${ELM_REVIEW+x}" ] || [ "$ELM_REVIEW" -ne 1 ]; then
 exit 0;
fi

ls -l
cd client
elm-analyse
