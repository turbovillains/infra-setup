#!/usr/bin/env bash
# Usage ./import-charts.sh <descriptor> <target-folder>
set -eu

import_charts() {
    local descriptor=${1:-import-charts.yml}
    local target=${2:-./docker/infra-charts/charts}
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
                    # Find last ten non-beta non-alpha or non-dev versions from repo
                    versions=$(curl -sL ${url}/index.yaml \
                        | yj \
                        | jq -r --arg name ${name} \
                        '[
                            .entries[$name]
                            | sort_by(.created)
                            | reverse
                            | .[]
                            | select(.version | test("beta|alpha|dev|test") | not)
                            | .version
                        ] | .[0:10] | join(" ")'
                    )
                fi
                for version in ${versions}; do
                    echo "Pulling ${name}@${version} from ${repo}"
                    helm pull --repo ${url} --destination ${target}/${repo} --version ${version} ${name}
                done
            done
        ) &
    done

    wait

    for repo_dir in ${target}/*; do
        (
            cd ${repo_dir}
            helm repo index ./
        )
    done
}

_main() {
    local source_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

    import_charts "${@:-}"
}

[[ "${BASH_SOURCE[0]}" != "${0}" ]] || _main "${@:-}"

# End of file
