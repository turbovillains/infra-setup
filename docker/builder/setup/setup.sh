#!/bin/bash -eu

export SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -d "${SOURCE_DIR}/setup.d" ]]; then
  for inc in ${SOURCE_DIR}/setup.d/*.sh; do
    if [[ -r ${inc} ]]; then
      echo "sourcing ${inc}"
      source ${inc}
    fi
  done
  unset inc
fi

# End of file
