#!/usr/bin/env bash -eux

SSH_PRIVATE_KEY=${SSH_PRIVATE_KEY:-}

mkdir -p /root/.ssh /home/${BUILDER_USER}/.ssh
chmod 700 /root/.ssh /home/${BUILDER_USER}/.ssh

if [[ ! -z "${SSH_PRIVATE_KEY}" ]]; then
    set -eu
    # http://docs.gitlab.com/ce/ci/ssh_keys/README.html
    which ssh-agent || ( apt-get update -y && apt-get install openssh-client -y )
    eval $(ssh-agent -s)
    echo "${SSH_PRIVATE_KEY}" | tee /root/.ssh/id_rsa | tee /home/${BUILDER_USER}/.ssh/id_rsa | tr -d '\r' | ssh-add - > /dev/null
    chmod 600 /root/.ssh/id_rsa /home/${BUILDER_USER}/.ssh/id_rsa
fi

ssh-keyscan ${GIT_SERVER_HOST} | tee /root/.ssh/known_hosts | tee /home/${BUILDER_USER}/.ssh/known_hosts