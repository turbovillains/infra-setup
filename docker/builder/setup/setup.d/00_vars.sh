#!/usr/bin/env bash -eux

export BUILDER_USER=builder

export ALL_PROXY=${HTTP_PROXY:-http://proxy.bo01.noroutine.me:3128}
export all_proxy=${HTTP_PROXY:-http://proxy.bo01.noroutine.me:3128}
export HTTP_PROXY=${HTTP_PROXY:-http://proxy.bo01.noroutine.me:3128}
export http_proxy=${HTTP_PROXY:-http://proxy.bo01.noroutine.me:3128}
export HTTPS_PROXY=${HTTPS_PROXY:-http://proxy.bo01.noroutine.me:3128}
export https_proxy=${HTTPS_PROXY:-http://proxy.bo01.noroutine.me:3128}
export NO_PROXY=${NO_PROXY:-".noroutine.me,.nrtn.dev,10.0.0.0/8,localhost,127.0.0.1"}
export no_proxy=${NO_PROXY:-".noroutine.me,.nrtn.dev,10.0.0.0/8,localhost,127.0.0.1"}

export SSH_PRIVATE_KEY=$(cat /run/secrets/ssh_private_key)
export INFRA_READONLY_TOKEN=$(cat /run/secrets/infra_readonly_token)