#!/usr/bin/env bash -eux

useradd --create-home --shell /bin/bash --uid 1000 --gid users --groups sudo,docker ${BUILDER_USER} && echo "${BUILDER_USER}:${BUILDER_USER}" | chpasswd
echo "${BUILDER_USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
visudo -c

cp /root/.bashrc /home/${BUILDER_USER}/.bashrc