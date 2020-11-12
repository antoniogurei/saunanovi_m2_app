#!/usr/bin/env bash
## =========================================================================
#   Reset Magento DB structure.
#
#   Usage: ./reset.sh
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
: "${BASE_URL:?}"
: "${BASE_URL_SECURE:?}"
: "${DB_HOST:?}"
: "${DB_NAME:?}"
: "${DB_PASS:?}"
: "${DB_USER:?}"
: "${DIR_MAGE:?}"
: "${LOCAL_GROUP:?}"
: "${LOCAL_OWNER:?}"
: "${MODE:?}"
: "${PHP_BIN:?}"
# local context vars
FILE_DUMP="mage_db"
FILE_ZIP="${FILE_DUMP}.tar.gz"
MYSQL_EXEC="mysql -h ${DB_HOST} -u ${DB_USER} --password=${DB_PASS} -D ${DB_NAME} -e "

info ""
info "========================================================================="
info "Reset DB using downloaded image."
info "========================================================================="

## =========================================================================
#   Perform processing (this script context)
## =========================================================================
info "Extract dump from archive (${DIR_THIS}/${FILE_ZIP})."
tar -zxf "${DIR_THIS}/${FILE_ZIP}" -C "${DIR_THIS}"

## =========================================================================
#   Check extracted dump and prepare it for restore
## =========================================================================
if test ! -e "${DIR_THIS}/${FILE_DUMP}"; then
  info "'${FILE_DUMP}' does not exist. Place Magento DB SQL dump to '${DIR_THIS}/${FILE_DUMP}' and launch this script again."
  exit 2
fi

info "Clean up DEFINER from '${FILE_DUMP}'."
sed -i 's/DEFINER=[^*]*\*/\*/g' "${DIR_THIS}/${FILE_DUMP}"

## =========================================================================
#   Drop DB and restore it from the dump
## =========================================================================
info "Restoring Magento db '${DB_NAME}' from dump '${DIR_THIS}/${FILE_DUMP}'..."
${MYSQL_EXEC} "drop database if exists ${DB_NAME}"
mysql -h "${DB_HOST}" -u "${DB_USER}" --password="${DB_PASS}" -e "create database ${DB_NAME} character set utf8 collate utf8_unicode_ci"
${MYSQL_EXEC} "source ${DIR_THIS}/${FILE_DUMP}"
${MYSQL_EXEC} "UPDATE core_config_data SET value='${BASE_URL}' WHERE path='web/unsecure/base_url'"
${MYSQL_EXEC} "UPDATE core_config_data SET value='${BASE_URL_SECURE}' WHERE path='web/secure/base_url'"

${MYSQL_EXEC} "source ${DIR_THIS}/migrate.sql"

info ""
info "DB '${DB_NAME}' is restored."

## =========================================================================
#   Cleanup extracted dump (leave ZIP only on the disk)
## =========================================================================
info ""
info "Remove plain dump '${FILE_DUMP}' to free disk space."
rm -f "${DIR_THIS}/${FILE_DUMP}"

## =========================================================================
#   Reset Magento to use updated DB and set filesystem permissions
## =========================================================================
info ""
info "Reset Magento to use updated DB."
${PHP_BIN} "${DIR_MAGE}/bin/magento" deploy:mode:set developer
${PHP_BIN} "${DIR_MAGE}/bin/magento" setup:upgrade
${PHP_BIN} "${DIR_MAGE}/bin/magento" setup:di:compile
${PHP_BIN} "${DIR_MAGE}/bin/magento" cache:flush
info "Setup permissions to filesystem."

info ""
if test -z "${LOCAL_OWNER}" || test -z "${LOCAL_GROUP}" || test -z "${DIR_MAGE}"; then
  info "Skip file system ownership and permissions setup."
else
  info "Set file system ownership (${LOCAL_OWNER}:${LOCAL_GROUP}) and permissions to '${DIR_MAGE}'..."
  chown -R "${LOCAL_OWNER}":"${LOCAL_GROUP}" "${DIR_MAGE}"
fi

info ""
info "========================================================================="
info "Database reset is complete."
info "========================================================================="
