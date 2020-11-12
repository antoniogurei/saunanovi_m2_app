#!/usr/bin/env bash
## =========================================================================
#   Download Magento DB from remote host to local folder.
#
#   Usage: ./get.sh
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
: "${DIR_BAK:?}"
: "${LOCAL_GROUP:?}"
: "${LOCAL_OWNER:?}"
: "${MODE:?}"
: "${SSH_DIR:?}"
: "${SSH_HOST:?}"
# local context vars
SSH_DIR_DB="${SSH_DIR}/db" # "/home/user/store/project/distr/db"
FILE_DUMP="mage_db"      # see '../../up/db/create.sh'
FILE_ZIP="${FILE_DUMP}.tar.gz"
REMOTE_PATH="${SSH_DIR_DB}/${FILE_ZIP}"

info ""
info "========================================================================="
info "DB image download is started in '${MODE}' mode."
info "========================================================================="

## =========================================================================
#   Perform processing (this script context)
## =========================================================================
info "Looking up for archive '${REMOTE_PATH}' at '${SSH_HOST}'."
if ssh "${SSH_HOST}" stat "${SSH_DIR_DB}/${FILE_ZIP}" \> /dev/null 2\>\&1; then
  info "File is found. Clean up old copies from local (${DIR_THIS}/${FILE_DUMP}*)."
  rm -f "${DIR_THIS}/${FILE_DUMP}*"
  info "Download '${SSH_HOST}:${REMOTE_PATH}' to '${DIR_THIS}/'."
  scp "${SSH_HOST}:${REMOTE_PATH}" "${DIR_THIS}/"
  test -f "${DIR_THIS}/${FILE_ZIP}" || (err "'${FILE_ZIP}' is not downloaded." && exit 16)
else
  err "Cannot find backup file '${SSH_DIR_DB}/${FILE_ZIP}'. Aborted."
  exit 1
fi

info ""
info "========================================================================="
info "DB image download is complete."
info "========================================================================="
