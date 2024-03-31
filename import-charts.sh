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
                local by_field=$(jq -r '.by // "version"' <<< ${chart})
                echo "Fetching ${name} by ${by_field}"
                mkdir -p ${target}/${repo}
                if [[ "${versions}" == "null" ]]; then
                    # Find last ten non-beta non-alpha or non-dev versions from repo
                    # for date conversion trick see https://github.com/jqlang/jq/issues/2224
                    if [[ "${by_field}" == "version" ]]; then
                        versions=$(curl -sL ${url}/index.yaml \
                            | yj \
                            | jq -r --arg name ${name} \
                            '[
                                .entries[$name]
                                | .[]
                                | select(.version | test("beta|alpha|dev|test|canary|rc|preview") | not)
                            ]
                            | sort_by(.version | sub("^v"; "") | split(".") | map(tonumber? // 0))
                            | reverse
                            | .[0:10]
                            | [ .[].version ]
                            | join(" ")'
                        )
                    elif [[ "${by_field}" == "created" ]]; then
                        versions=$(curl -sL ${url}/index.yaml \
                            | yj \
                            | jq -r --arg name ${name} \
                            '[
                                .entries[$name]
                                | .[]
                                | select(.version | test("beta|alpha|dev|test|canary|rc|preview") | not)
                            ]
                            | sort_by(.created | .[0:19] +"Z" | fromdateiso8601)
                            | reverse
                            | .[0:10]
                            | [ .[].version ]
                            | join(" ")'
                        )
                    fi
                    echo "${name}: ${versions}"
                fi
                for version in ${versions}; do
                    if [[ ! -f ${target}/${repo}/${name}-${version}.tgz ]]; then
                        echo "Pulling ${name}@${version} from ${repo}"
                        helm pull --repo ${url} --destination ${target}/${repo} --version ${version} ${name}
                    else
                        echo "Found ${name}@${version} from ${repo}"
                    fi
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
