#!/usr/bin/env bash
## =========================================================================
#   Create media dump.
#
#   Usage: ./create.sh live|work
#
#       This is friendly user script, not user friendly
#       There are no protection from mistakes.
#       Use it if you know how it works.
## =========================================================================
# shellcheck disable=SC1090 # "Can't follow non-constant source."
# root directory (relative to the current shell script, not to the execution point)
# http://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_06_02
DIR_ROOT=${DIR_ROOT:=$(cd "$(dirname "$0")/../../../../" && pwd)}
# include commons for standalone running
. "${DIR_ROOT}/bin/commons.sh" "${1:-live}"

## =========================================================================
#   Setup working environment
## =========================================================================
# check external vars used in this script (see cfg.work.sh)
: "${DIR_BAK:?}"
: "${MODE:?}"
# locally used vars
DIR_MAGE="${DIR_ROOT}/${MODE}" # root folder for Magento application
DIR_BAK_MEDIA=${DIR_BAK}/media
DIR_MAGE_MEDIA="${DIR_MAGE}/pub/media"
FILE_DUMP="biobox_media"
PATH_DUMP_ZIP="${DIR_BAK_MEDIA}/${FILE_DUMP}.tar.gz"

info ""
info "************************************************************************"
info "Media image creation is started in '${MODE}' mode."
info "************************************************************************"

## =========================================================================
#   Perform processing
## =========================================================================
info ""
info "Remove old dump '${PATH_DUMP_ZIP}'."
rm -f "${PATH_DUMP_ZIP}"
info "Compressing media '${DIR_MAGE_MEDIA}' into '${PATH_DUMP_ZIP}'..."
# don't set trailing slash for directories
EXCLUDES="--exclude=*.minify --exclude=./tmp --exclude=./catalog/product/cache"
# don't place ${EXCLUDES} between double quotes, will not work
tar ${EXCLUDES} -zcf "${PATH_DUMP_ZIP}" -C "${DIR_MAGE_MEDIA}" .

info " "
info "************************************************************************"
info "  Media dump creation is completed."
info "************************************************************************"
