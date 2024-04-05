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

    local source_registry="$(get_registry ${fq_image_name})"
    local image_name=$(get_name ${fq_image_name})
    local image_ref=$(get_ref ${fq_image_name})
    local image_tag=$(get_tag ${fq_image_name})

    local archived_fq_image_name=${source_registry}/${image_name}:${image_tag}

    # Pull as specified, possibly with sha pointer, but save as given tag
    # retag as archived image to make sure sha version pointers produce real tags
    docker pull ${fq_image_name}
    docker tag ${fq_image_name} ${archived_fq_image_name}
    image_archive="$(echo ${archived_fq_image_name} | tr '/:' '-').zst"
    docker save ${archived_fq_image_name} | zstd -T0 >${image_archive}
    ls -sh1 ${image_archive}

    rsync -e "ssh -o StrictHostKeyChecking=no" \
        --rsync-path="sudo mkdir -p /ifs/attic/infra/${infra_bucket}/images && sudo rsync" \
        ${image_archive} \
        oleksii@tank.noroutine.me:/ifs/attic/infra/${infra_bucket}/images/${image_archive}

    rm ${image_archive}
}

archive_folder() {
    local path=${1:-}
    local target=${2:-}
    local infra_bucket=${3:-${INFRA_VERSION}}

    rsync -av -e "ssh -o StrictHostKeyChecking=no" \
        --rsync-path="sudo mkdir -p /ifs/attic/infra/${infra_bucket}/${target} && sudo rsync" \
        ${path}/ \
        oleksii@tank.noroutine.me:/ifs/attic/infra/${infra_bucket}/${target}
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
    echo "docker build ${implicit_args} ${docker_build_args} -t ${DOCKER_HUB}/${target} docker/${component}"

    docker build ${implicit_args} ${docker_build_args} -t ${DOCKER_HUB}/${target} docker/${component}
    docker push ${DOCKER_HUB}/${target}

    if [[ ! -z "${CI_COMMIT_TAG:-}" ]]; then
        archive_image ${DOCKER_HUB}/${target} ${INFRA_VERSION}
    fi

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
    local migration_options=${3:-}

    # declare supported options here
    local prepend_name=

    # declare supplied options
    local supplied_options=$(echo ${migration_options} | sed 's,:::, ,g' )
    [[ -z ${supplied_options} ]] || declare ${supplied_options}

    local source_image=${source_registry}/${image_name}:${image_ref}
    local target_image=${target_registry}/${prepend_name}${image_name}:${image_tag}

    if which crane 2>&1> /dev/null; then
        crane copy ${source_image} ${target_image}
    else
        echo "Falling back to shell"
        # We are checking for ref, but pushing only tag
        set +e
        docker manifest inspect ${target_registry}/${prepend_name}${image_name}:${image_ref} 2>&1> /dev/null
        local inspect_code=$?
        set -e

        if [[ "${inspect_code}" != 0 ]]; then
            # we pull the ref, but push the tag
            docker pull ${source_image}
            docker tag ${source_image} ${target_image}
            docker push ${target_image}
            docker rmi ${source_image} ${target_image}
        fi
    fi
}

strip_options() {
    local image_entry=$1
    local options_regex='(.*):::(.*)'
    if [[ $image_entry =~ $options_regex ]]; then
        echo -n ${BASH_REMATCH[1]}
    else
        echo -n $image_entry
    fi
}

get_options() {
    local options_regex='(.*):::(.*)'
    if [[ $1 =~ $options_regex ]]; then
        echo -n ${BASH_REMATCH[2]}
    fi
}


get_registry() {
    local image=$(strip_options $1)
    [[ -z ${image} ]] && return
    if [[ ${image} =~ ^([^\/]+\.[^\/]+)\/ ]]; then
        echo -n ${BASH_REMATCH[1]}
    else
        echo -n docker.io
    fi
}

get_ref() {
    local image=$(strip_options $1)
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
    local image=$(strip_options $1)
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
    local image=$(strip_options $1)
    [[ -z ${image} ]] && return
    if [[ ${image} =~ ([^\/]+\.[^\/]+\/)?([^:]+)(:.+)?$ ]]; then
        echo -n ${BASH_REMATCH[2]}
    fi
}
