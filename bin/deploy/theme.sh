#!/usr/bin/env bash
## =========================================================================
#   Add theme files.
#
#       This is friendly user script, not user friendly
#       There are no protection from mistakes.
#       Use it if you know how it works.
## =========================================================================
# shellcheck disable=SC1090
# root directory (relative to the current shell script, not to the execution point)
# http://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_06_02
DIR_ROOT=${DIR_ROOT:=$(cd "$(dirname "$0")/../../" && pwd)}
DIR_THIS=$(cd "$(dirname "$0")" && pwd)

## =========================================================================
#   Validate deployment mode and load configuration.
## =========================================================================
if test -z "${MODE}"; then
  . "${DIR_ROOT}/bin/commons.sh" "${1}" # standalone running (./script.sh [work|live])
else
  . "${DIR_ROOT}/bin/commons.sh" # this script is child of other script
fi

## =========================================================================
#   Setup & validate working environment
## =========================================================================
: "${DIR_LINK_LOG:?}"
: "${DIR_MAGE:?}"
: "${LOCAL_GROUP:?}"
: "${LOCAL_OWNER:?}"
# local context vars
#DIR_SRC_ORIG="${DIR_ROOT}/theme/orig"   # root folder for theme's original sources
#DIR_SRC_OWN="${DIR_ROOT}/theme/own"    # root folder for theme's customization

## =========================================================================
#   Perform processing
## =========================================================================
info ""
info "************************************************************************"
info "  Add theme files to the project."
info "************************************************************************"
cd "${DIR_ROOT}" || exit 255
#rsync -a "${DIR_SRC_ORIG}/" "${DIR_MAGE}/"
#rsync -a "${DIR_SRC_OWN}/" "${DIR_MAGE}/"

info ""
info "************************************************************************"
info "  Theme files are added to the project."
info "************************************************************************"
