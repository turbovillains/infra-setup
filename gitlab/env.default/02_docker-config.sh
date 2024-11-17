#!/usr/bin/env bash -eu

[[ ! -z ${DOCKER_CFG:-} ]]

mkdir -p ~/.docker
echo "${DOCKER_CFG:-}" | base64 --decode > ~/.docker/config.json

export DOCKER_CLI_EXPERIMENTAL=enabled
export DOCKER_BUILDKIT=1

docker buildx ls

docker buildx ls --format json | jq -r .Name | grep mybuilder \
  || docker buildx create --platform linux/amd64,linux/arm64 --driver=docker-container --name=mybuilder --use --bootstrap

# End of file
