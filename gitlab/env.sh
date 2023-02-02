#!/bin/bash -eu

include_env() {
    local source_dir=${1:-}
    local deploy_environment=${2:-}

    [[ ! -z ${source_dir} ]]
    [[ ! -z ${deploy_environment} ]]

    # export ALL_PROXY=${HTTP_PROXY:-}
    # export all_proxy=${HTTP_PROXY}
    # export HTTP_PROXY=${HTTP_PROXY:-}
    # export http_proxy=${HTTP_PROXY}
    # export HTTPS_PROXY=${HTTP_PROXY}
    # export https_proxy=${HTTP_PROXY}
    # export FTP_PROXY=${HTTP_PROXY}
    # export ftp_proxy=${HTTP_PROXY}

    export ALL_PROXY=
    export all_proxy=
    export HTTP_PROXY=
    export http_proxy=
    export HTTPS_PROXY=
    export https_proxy=
    export FTP_PROXY=
    export ftp_proxy=
    git config --global --unset http.proxy || true
    git config --unset http.proxy || true

    export NO_PROXY=${NO_PROXY:-}
    export no_proxy=${NO_PROXY}

    if [[ -d "${source_dir}/env.${deploy_environment}" ]]; then
      export PROJECT_SOURCE_DIR=$(dirname ${source_dir})
      export DEPLOY_ENVIRONMENT=${deploy_environment}
      export DEPLOY_ENVIRONMENT_DIR=${source_dir}/env.${deploy_environment}

      echo "Export variables for ${DEPLOY_ENVIRONMENT}"

      for inc in ${source_dir}/env.${deploy_environment}/*.sh; do
        if [[ -r ${inc} ]]; then
          source ${inc}
        fi
      done
      unset inc
    fi
}

_main() {
    local source_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
    local deploy_environment=${DEPLOY_ENVIRONMENT:-default}
    include_env ${source_dir} ${deploy_environment}
}

_main "${@:-}"

# End of file
