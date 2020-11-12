#!/usr/bin/env bash
## =========================================================================
#   Integration script to download image and renew component.
#
#   Usage: ./do.sh
## =========================================================================
# shellcheck disable=SC1090 # "Can't follow non-constant source."
# Get ROOT directory from parent script or calculate relative.
DIR_ROOT=${DIR_ROOT:-$(cd "$(dirname "$0")/../../../../" && pwd)}
# this script directory
DIR_THIS=$(cd "$(dirname "$0")" && pwd)
# define deployment configuration to use (work|live)
MODE="${1:-work}"

/bin/bash "${DIR_THIS}/get.sh" "${MODE}"
/bin/bash "${DIR_THIS}/renew.sh" "${MODE}"
