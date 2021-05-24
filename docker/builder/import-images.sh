#!/bin/bash -eu

get_registry() {
    local image=$1
    [[ -z ${image} ]] && return
    if [[ ${image} =~ ^([^\/]+\.[^\/]+)\/ ]]; then
        echo -n ${BASH_REMATCH[1]}
    else
        echo -n docker.io
    fi
}

get_tag() {
    local image=$1
    [[ -z ${image} ]] && echo -n "latest" && return
    if [[ ${image} =~ :([^\/]+) ]]; then
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

migrate_image() {
    local image=$1
    [[ -z ${image} ]] && return
    local source_registry=$(get_registry ${image})
    local target_registry=${2}
    [[ -z ${target_registry} ]] && return
    local image_name=$(get_name ${image})
    local image_tag=$(get_tag ${image})

    docker pull ${source_registry}/${image_name}:${image_tag}
    docker tag ${source_registry}/${image_name}:${image_tag} ${target_registry}/${image_name}:${image_tag}
    docker push ${target_registry}/${image_name}:${image_tag}
}

line() {
    local width=40
    eval printf '%.0s-' {1..${width}}
}

declare -a images=(
    "golang:${GO_VERSION:-latest}-buster"
)

TARGET_REGISTRY=${1:-cr.nrtn.dev}

for image in ${images[@]}; do
    printf "\n-:[ migrating %s/%s:%s to %s ]:-`line`\n" \
        $(get_registry $image) $(get_name $image) $(get_tag $image) \
        ${TARGET_REGISTRY}
    migrate_image ${image} ${TARGET_REGISTRY} 
done

# End of file