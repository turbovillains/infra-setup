#!/usr/bin/env bash

set -eu

import_charts() {
    local descriptor=${1:-import-charts.yml}
    local target=${2:-./charts}
    for repo in $(yj -y < ${descriptor} | jq -r '.helm[] | .name'); do
        local url=$(yj -y < ${descriptor} \
            | jq -r --arg repo ${repo} '.helm[] | select(.name==$repo) | .url')
        mapfile -t charts < <(yj -y < ${descriptor} \
            | jq -c -r --arg repo ${repo} '.helm[] | select(.name==$repo) | .charts // [] | .[]')
        (
            for chart in "${charts[@]}"; do
                local name=$(jq -r .name <<< ${chart})
                local versions=$(jq -r .version <<< ${chart})
                mkdir -p ${target}/${repo}
                if [[ "${versions}" == "null" ]]; then
                    # Find last two versions from repo
                    versions=$(curl -sL ${url}/index.yaml \
                        | yj | jq -r --arg name ${name} '.entries[$name] | sort_by(.created) | reverse | .[0:2] | .[].version')
                fi
                for version in ${versions}; do
                    echo "Pulling ${name}@${version} from ${repo}"
                    helm pull --repo ${url} --destination ${target}/${repo} --version ${version} ${name}
                done
            done
        ) &
    done

    wait
}

_main() {
    local source_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

    import_charts "${@:-}"
}

[[ "${BASH_SOURCE[0]}" != "${0}" ]] || _main "${@:-}"

# End of file
