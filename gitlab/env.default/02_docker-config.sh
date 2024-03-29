#!/usr/bin/env bash -eu

[[ ! -z ${DOCKER_CFG:-} ]]

mkdir -p ~/.docker
echo "${DOCKER_CFG:-}" | base64 --decode > ~/.docker/config.json

export DOCKER_CLI_EXPERIMENTAL=enabled
export DOCKER_BUILDKIT=1

# End of file
