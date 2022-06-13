#!/bin/bash -eux

build_image() {
    local component=${1:-}
    local target=${2:-}
    shift 2

    local docker_build_args=${@:-}

    test ! -z ${component}
    test ! -z ${target}

    test ! -z ${DOCKER_HUB:-}
    test ! -z ${INFRA_VERSION:-}
    test ! -z ${BUILDER_USER:-}

    local implicit_args="--no-cache \
        --secret id=ssh_private_key,src=/home/${BUILDER_USER}/.ssh/id_rsa \
        --secret id=infra_readonly_token,src=/home/${BUILDER_USER}/.infra_readonly_token \
        --build-arg HTTP_PROXY \
        --build-arg HTTPS_PROXY \
        --build-arg NO_PROXY \
        --build-arg DOCKER_HUB \
        --build-arg INFRA_VERSION \
        --build-arg DOCKER_NAMESPACE"

    echo "Building ${component} as ${target}"

    docker build ${implicit_args} ${docker_build_args} -t ${DOCKER_HUB}/${target} docker/${component}
    docker push ${DOCKER_HUB}/${target}
    docker rmi ${DOCKER_HUB}/${target}
}

_main() {
    local source_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
    source ${source_dir}/env.sh
    
    build_image "${@}"
}

[[ "${BASH_SOURCE[0]}" != "${0}" ]] || _main "${@:-}"
