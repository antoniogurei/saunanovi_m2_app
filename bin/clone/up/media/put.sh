#!/usr/bin/env bash
## =========================================================================
#   Upload media dump to the storage using 'scp'.
#
#   Usage: ./put.sh live|work
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
#   Setup working environment
## =========================================================================
# check external vars used in this script (see cfg.work.sh)
: "${DIR_BAK:?}"
: "${MODE:?}"
: "${SSH_DIR:?}"
: "${SSH_HOST:?}"
# locally used vars
DIR_BAK_MEDIA="${DIR_BAK}/media" # backup directory to get ZIP file from
SSH_DIR_MEDIA="${SSH_DIR}/media" # remote directory to upload ZIP to
FILE_DUMP="biobox_media"         # see "./create.sh"
FILE_ZIP="${FILE_DUMP}.tar.gz"
PATH_DUMP_LOCAL="${DIR_BAK_MEDIA}/${FILE_ZIP}"
SUFFIX="$(date '+_%Y%m%d_%H%M%S')"
FILE_COPY="${FILE_DUMP}${SUFFIX}.tar.gz"
REMOTE_PATH="${SSH_DIR_MEDIA}/${FILE_ZIP}"

info ""
info "************************************************************************"
info "Media image upload is started in '${MODE}' mode."
info "************************************************************************"

## =========================================================================
#   Perform processing
## =========================================================================
if test -f "${PATH_DUMP_LOCAL}"; then
  info "Media image file '${PATH_DUMP_LOCAL}' is found."
else
  info "There is no file '${PATH_DUMP_LOCAL}'. Abort."
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
ssh "${SSH_HOST}" cp "${REMOTE_PATH}" "${SSH_DIR_MEDIA}"/"${FILE_COPY}"

# clean up old archives
info "Delete '${FILE_DUMP}*.tar.gz' files older than 8 days from '${SSH_DIR_MEDIA}'."
ssh "${SSH_HOST}" find "${SSH_DIR_MEDIA}" -type f -name "${FILE_DUMP}*.tar.gz" -mtime +8 -exec "rm -f {} \;"

info ""
info "************************************************************************"
info "Media image upload is completed."
info "************************************************************************"
