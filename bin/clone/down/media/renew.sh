#!/usr/bin/env bash
## =========================================================================
#   Renew Magento media structure using downloaded image.
#
#   Usage: ./renew.sh
#
#       This is friendly user script, not user friendly
#       There are no protection from mistakes.
#       Use it if you know how it works.
## =========================================================================
# shellcheck disable=SC1090 # "Can't follow non-constant source."
# Get ROOT directory from parent script or calculate relative.
DIR_ROOT=${DIR_ROOT:-$(cd "$(dirname "$0")/../../../../" && pwd)}
# this script directory
DIR_THIS=$(cd "$(dirname "$0")" && pwd)
# include commons for standalone running
. "${DIR_ROOT}/bin/commons.sh" "${1:-work}"

## =========================================================================
#   Setup working environment
## =========================================================================
# check external vars used in this script (see cfg.work.sh)
: "${DIR_LINK_MEDIA:?}"
: "${LOCAL_GROUP:?}"
: "${LOCAL_OWNER:?}"
: "${MODE:?}"
# set working vars (re-link global vars)
FILE_DUMP="biobox_media" # see './get.sh'
FILE_ZIP="${FILE_DUMP}.tar.gz"

info ""
info "========================================================================="
info "Media renewal is started in '${MODE}' mode."
info "========================================================================="

## =========================================================================
#   Perform processing
## =========================================================================
info "Clean up target media folder ${DIR_LINK_MEDIA}."
rm -fr "${DIR_LINK_MEDIA:?}/*"

info "Extract dump from archive '${FILE_ZIP}'."
tar -zxf "${DIR_THIS}/${FILE_ZIP}" -C "${DIR_LINK_MEDIA}"

info "Set file system ownership (${LOCAL_OWNER}:${LOCAL_GROUP}) and permissions to '${DIR_LINK_MEDIA}/'..."
chown -R "${LOCAL_OWNER}:${LOCAL_GROUP}" "${DIR_LINK_MEDIA}/"

info ""
info "========================================================================="
info "Media renewal is complete."
info "========================================================================="
