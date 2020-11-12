#!/usr/bin/env bash
## =========================================================================
#   Create DB dump.
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
: "${DB_NAME:?}"
: "${DB_PASS:?}"
: "${DB_USER:?}"
: "${DIR_BAK:?}"
: "${MODE:?}"
# locally used vars
DIR_BAK_DB="${DIR_BAK}/db"
FILE_DUMP="mage_db"
PATH_DUMP=${DIR_BAK_DB}/${FILE_DUMP}
PATH_DUMP_ZIP=${DIR_BAK_DB}/${FILE_DUMP}.tar.gz

info ""
info "************************************************************************"
info "DB image creation is started in '${MODE}' mode."
info "************************************************************************"

## =========================================================================
#   Perform processing
## =========================================================================
info ""
mkdir -p "${DIR_BAK_DB}"
info "Dumping Magento db '${DB_NAME}' into '${PATH_DUMP}'..."
IGNORE="--ignore-table=${DB_NAME}.amasty_geoip_block"
IGNORE="${IGNORE} --ignore-table=${DB_NAME}.amasty_geoip_location"
mysqldump --add-locks \
  --lock-tables \
  --skip-quick \
  --skip-tz-utc \
  --user="${DB_USER}" \
  --password="${DB_PASS}" \
  "${IGNORE}" \
  "${DB_NAME}" >"${PATH_DUMP}"
info "Remove old dump '${PATH_DUMP_ZIP}'."
rm -f "${PATH_DUMP_ZIP}"
info "Compressing dump into '${PATH_DUMP_ZIP}'..."
tar -zcf "${PATH_DUMP_ZIP}" -C "${DIR_BAK_DB}" "${FILE_DUMP}"
info "Remove plain dump '${PATH_DUMP}'."
rm "${PATH_DUMP}"

info ""
info "************************************************************************"
info "DB image creation is completed."
info "************************************************************************"
