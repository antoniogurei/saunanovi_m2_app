#!/usr/bin/env bash
## =========================================================================
#   Integration script to create and upload image.
#
#   Usage: ./do.sh live|work
## =========================================================================
# shellcheck disable=SC1090 # "Can't follow non-constant source."
# this script directory
DIR_THIS=$(cd "$(dirname "$0")" && pwd)

# define deployment configuration to use (work|live)
MODE="${1:-live}"

. "${DIR_THIS}/create.sh" "${MODE}"
. "${DIR_THIS}/put.sh" "${MODE}"
