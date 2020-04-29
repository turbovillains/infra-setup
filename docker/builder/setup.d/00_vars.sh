#!/usr/bin/env bash -eux

export NOMAD_VERSION=${NOMAD_VERSION:-0.10.0}
export TERRAFORM_VERSION=${TERRAFORM_VERSION:-0.12.18}
export CONSUL_VERSION=${CONSUL_VERSION:-1.6.1}
export VAULT_VERSION=${VAULT_VERSION:-1.2.3}
export ENVCONSUL_VERSION=${ENVCONSUL_VERSION:-0.9.0}
export CONSUL_TEMPLATE_VERSION=${CONSUL_TEMPLATE_VERSION:-0.22.0}

export HTTP_PROXY=http://bo01-vm-proxy01.node.bo01.noroutine.me:3128
export HTTPS_PROXY=http://bo01-vm-proxy01.node.bo01.noroutine.me:3128
export NO_PROXY="*.noroutine.me,localhost,127.0.0.1"