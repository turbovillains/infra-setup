#!/usr/bin/env bash -eu

[[ ! -z ${INFRA_READONLY_TOKEN:-} ]]
[[ ! -z ${BUILDER_USER:-} ]]

echo "${INFRA_READONLY_TOKEN}" > /home/${BUILDER_USER}/.infra_readonly_token

# End of file
