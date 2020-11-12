#!/usr/bin/env bash
## =========================================================================
#   Create 'logrotate' configuration.
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
PATH_SOURCE="${DIR_THIS}/logrotate/tmpl.conf"
PATH_TARGET="${DIR_MAGE}/var/logrotate.conf"

## =========================================================================
#   Perform processing
## =========================================================================
info ""
info "************************************************************************"
info "  Create 'logrotate' configuration:"
info "      ${PATH_TARGET}"
info "************************************************************************"
cd "${DIR_ROOT}" || exit 255
mkdir -p "${DIR_LINK_LOG}/old"
envsubst <"${PATH_SOURCE}" >"${PATH_TARGET}"

info ""
info "************************************************************************"
info "  'logrotate' configuration creation is complete."
info "************************************************************************"
