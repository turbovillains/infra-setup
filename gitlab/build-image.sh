#!/usr/bin/env bash

_main() {
    set -eu

    local source_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
    source ${source_dir}/env.sh

    build_image "${@}"
}

[[ "${BASH_SOURCE[0]}" != "${0}" ]] || _main "${@:-}"
