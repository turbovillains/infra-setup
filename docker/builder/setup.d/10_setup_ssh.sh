#!/usr/bin/env bash -eux

SSH_PRIVATE_KEY=${SSH_PRIVATE_KEY:-}

mkdir -p ~/.ssh
chmod 700 ~/.ssh

if [[ ! -z "${SSH_PRIVATE_KEY}" ]]; then
    set -eu
    # http://docs.gitlab.com/ce/ci/ssh_keys/README.html
    which ssh-agent || ( apt-get update -y && apt-get install openssh-client -y )
    eval $(ssh-agent -s)
    echo "${SSH_PRIVATE_KEY}" | tee -a ~/.ssh/id_rsa | tr -d '\r' | ssh-add - > /dev/null
    chmod 600 ~/.ssh/id_rsa
fi

ssh-keyscan ${GIT_SERVER_HOST} | tee -a ~/.ssh/known_hosts