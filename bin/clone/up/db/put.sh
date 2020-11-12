#!/usr/bin/env bash
## =========================================================================
#   Upload DB dump to the remote storage.
#
#   Usage: ./upload.sh live|work
#
#       This is friendly user script, not user friendly
#       There are no protection from mistakes.
#       Use it if you know how it works.
## =========================================================================
# shellcheck disable=SC1090 # "Can't follow non-constant source."
# shellcheck disable=SC2029 # "Note that, unescaped, this expands on the client side."
# define project root (if not defined in the parent script)
# http://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_06_02
DIR_ROOT=${DIR_ROOT:=$(cd "$(dirname "$0")/../../../../" && pwd)}
# include commons for standalone running
. "${DIR_ROOT}/bin/commons.sh" "${1:-live}"

## =========================================================================
#   Setup working environment (this script context)
## =========================================================================
# check external vars used in this script (see cfg.work.sh)
: "${SSH_HOST:?}"
: "${SSH_DIR:?}"
: "${DIR_BAK:?}"
: "${MODE:?}"
# locally used vars
DIR_BACK_DB="${DIR_BAK}/db" # backup directory to get ZIP file from
SSH_DIR_DB="${SSH_DIR}/db"  # remote directory to upload ZIP to
FILE_DUMP="mage_db"       # see "./create.sh"
FILE_ZIP="${FILE_DUMP}.tar.gz"
PATH_DUMP_LOCAL="${DIR_BACK_DB}/${FILE_ZIP}"
SUFFIX="$(date '+_%Y%m%d_%H%M%S')"
FILE_COPY="${FILE_DUMP}${SUFFIX}.tar.gz"
REMOTE_PATH="${SSH_DIR_DB}/${FILE_ZIP}"

info ""
info "************************************************************************"
info "DB image upload is started in '${MODE}' mode."
info "************************************************************************"

## =========================================================================
#   Perform processing
## =========================================================================
if test -f "${PATH_DUMP_LOCAL}"; then
  info "App image file '${PATH_DUMP_LOCAL}' is found."
else
  info "There is not file '${PATH_DUMP_LOCAL}'. Abort."
  exit 16
fi

# remove archive from the network storage
if ssh "${SSH_HOST}" stat "${REMOTE_PATH}" \> /dev/null 2\>\&1; then
  info "Remove old dump '${REMOTE_PATH}' from '${SSH_HOST}'."
  ssh "${SSH_HOST}" rm "${REMOTE_PATH}"
fi

# upload archive to the network storage
info "Copy '${PATH_DUMP_LOCAL}' to '${SSH_HOST}:${REMOTE_PATH}'."
scp "${PATH_DUMP_LOCAL}" "${SSH_HOST}:${REMOTE_PATH}"
info "Upload is complete."

# rotate remote archives
info "Copy remote file '${FILE_ZIP}' to '${FILE_COPY}'."
ssh "${SSH_HOST}" cp "${REMOTE_PATH}" "${SSH_DIR_DB}"/"${FILE_COPY}"

# clean up old archives
info "Delete '${FILE_DUMP}*.tar.gz' files older than 8 days from '${SSH_DIR_DB}'."
# don't use " with env. vars below, error will occured
ssh "${SSH_HOST}" "find ${SSH_DIR_DB} -type f -name ${FILE_DUMP}*.tar.gz -mtime +8 -exec rm -f {} \;"

info ""
info "************************************************************************"
info "DB image upload is uploaded to network storage."
info "************************************************************************"
