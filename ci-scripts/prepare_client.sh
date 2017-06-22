#!/bin/sh
set -e

# ---------------------------------------------------------------------------- #
#
# Prepare client.
#
# ---------------------------------------------------------------------------- #

# Check the current build.
if [ -z "${BUILD_CLIENT+x}" ] || [ "$BUILD_CLIENT" -ne 1 ]; then
 exit 0;
fi

sysconfcpus -n 2 elm-make --yes
cp ./client/src/elm/LocalConfig.Example.elm ./client/src/elm/LocalConfig.elm
