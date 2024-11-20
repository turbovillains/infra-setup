#!/usr/bin/env bash

include_env() {
    local source_dir=${1:-}
    local deploy_environment=${2:-}

    [[ ! -z ${source_dir} ]]
    [[ ! -z ${deploy_environment} ]]

    git config --global --unset http.proxy || true
    git config --unset http.proxy || true

    if [[ -d "${source_dir}/env.${deploy_environment}" ]]; then
      export PROJECT_SOURCE_DIR=$(dirname ${source_dir})
      export DEPLOY_ENVIRONMENT=${deploy_environment}
      export DEPLOY_ENVIRONMENT_DIR=${source_dir}/env.${deploy_environment}

      echo "Export common variables"
      for inc in ${source_dir}/env.common/*.sh; do
        if [[ -r ${inc} ]]; then
          echo ${inc}
          source ${inc}
        fi
      done
      unset inc

      echo "Export variables for ${DEPLOY_ENVIRONMENT}"
      for inc in ${source_dir}/env.${deploy_environment}/*.sh; do
        if [[ -r ${inc} ]]; then
          echo ${inc}
          source ${inc}
        fi
      done
      unset inc
    fi
}

_main() {
    set -eu

    local source_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
    local deploy_environment=${DEPLOY_ENVIRONMENT:-default}
    include_env ${source_dir} ${deploy_environment}
}

_main "${@:-}"

# End of file
