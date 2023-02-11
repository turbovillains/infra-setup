line() {
    local width=40
    # if [[ ! -z $TERM ]]; then
    #     width=$(tput cols)
    # fi

    eval printf '%.0s-' {1..${width}}
}

archive_image() {
    local fq_image_name=${1:-}
    local infra_bucket=${2:-${INFRA_VERSION}}

    image_archive="$(echo ${fq_image_name} | tr '/:' '-').bz2"
    docker save ${fq_image_name} | bzip2 >${image_archive}
    ls -sh1 ${image_archive}

    rsync -e "ssh -o StrictHostKeyChecking=no" \
        --rsync-path="sudo mkdir -p /ifs/bo01/infra/${infra_bucket} && sudo rsync" \
        ${image_archive} \
        oleksii@tank.noroutine.me:/ifs/bo01/infra/${infra_bucket}/${image_archive}

    rm ${image_archive}
}

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
        --build-arg DOCKER_HUB \
        --build-arg INFRA_VERSION \
        --build-arg DOCKER_NAMESPACE"
        # --build-arg HTTP_PROXY \
        # --build-arg HTTPS_PROXY \
        # --build-arg NO_PROXY \

    echo "Building ${component} as ${target}"

    docker build ${implicit_args} ${docker_build_args} -t ${DOCKER_HUB}/${target} docker/${component}
    docker push ${DOCKER_HUB}/${target}

    archive_image ${DOCKER_HUB}/${target} ${INFRA_VERSION}

    docker rmi ${DOCKER_HUB}/${target}
}

migrate_image() {
    local image=${1:-}
    [[ -z ${image} ]] && return
    local source_registry="$(get_registry ${image})"
    local target_registry=${2:-}
    [[ -z ${target_registry} ]] && return
    local image_name=$(get_name ${image})
    local image_ref=$(get_ref ${image})
    local image_tag=$(get_tag ${image})

    # We are checking for ref, but pushing only tag
    set +e
    docker manifest inspect ${target_registry}/${image_name}:${image_ref} 2>&1> /dev/null
    local inspect_code=$?
    set -e

    if [[ "${inspect_code}" != 0 ]]; then
        # we pull the ref, but push the tag
        docker pull ${source_registry}/${image_name}:${image_ref}
        docker tag ${source_registry}/${image_name}:${image_ref} ${target_registry}/${image_name}:${image_tag}
        docker push ${target_registry}/${image_name}:${image_tag}
        docker rmi ${source_registry}/${image_name}:${image_ref} ${target_registry}/${image_name}:${image_tag}
    fi

}

get_registry() {
    local image=$1
    [[ -z ${image} ]] && return
    if [[ ${image} =~ ^([^\/]+\.[^\/]+)\/ ]]; then
        echo -n ${BASH_REMATCH[1]}
    else
        echo -n docker.io
    fi
}

get_ref() {
    local image=$1
    [[ -z ${image} ]] && echo -n "latest" && return

    # tag with sha
    if [[ ${image} =~ :([^\/]+)@sha256:([A-Fa-f0-9]{64}) ]]; then
        echo -n ${BASH_REMATCH[1]}@sha256:${BASH_REMATCH[2]}
    # just sha
    elif [[ ${image} =~ @sha256:([A-Fa-f0-9]{64}) ]]; then
        echo -n @sha256:${BASH_REMATCH[1]}
    # just tag
    elif [[ ${image} =~ :([^\/]+) ]]; then
        echo -n ${BASH_REMATCH[1]}
    else
        echo -n "latest"
    fi
}

get_tag() {
    local image=$1
    [[ -z ${image} ]] && echo -n "latest" && return

    # tag with sha
    if [[ ${image} =~ :([^\/]+)@sha256:([A-Fa-f0-9]{64}) ]]; then
        echo -n ${BASH_REMATCH[1]}
    # just sha
    elif [[ ${image} =~ @sha256:([A-Fa-f0-9]{64}) ]]; then
        echo -n "latest"
    # just tag
    elif [[ ${image} =~ :([^\/]+) ]]; then
        echo -n ${BASH_REMATCH[1]}
    else
        echo -n "latest"
    fi
}

get_name() {
    local image=$1
    [[ -z ${image} ]] && return
    if [[ ${image} =~ ([^\/]+\.[^\/]+\/)?([^:]+)(:.+)?$ ]]; then
        echo -n ${BASH_REMATCH[2]}
    fi
}
