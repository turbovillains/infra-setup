#!/bin/bash -eux

SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [[ -d "${SOURCE_DIR}/setup.d" ]]; then
  for inc in ${SOURCE_DIR}/setup.d/*.sh; do
    if [[ -r ${inc} ]]; then
      source ${inc}
    fi
  done
  unset inc
fi

# End of file