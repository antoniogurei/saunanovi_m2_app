#!/usr/bin/env bash
##
# Deploy application in 'live' mode w/o DB re-creation.
##
DIR_ROOT=$(cd "$(dirname "$0")/" && pwd)
"${DIR_ROOT}/bin/deploy/main.sh" -d live
