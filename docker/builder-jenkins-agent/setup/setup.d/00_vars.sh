#!/usr/bin/env bash -eux

export BUILDER_USER=${BUILDER_USER:-builder}

export SSH_PRIVATE_KEY=$(cat /run/secrets/ssh_private_key)
export INFRA_READONLY_TOKEN=$(cat /run/secrets/infra_readonly_token)
