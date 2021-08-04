#!/usr/bin/env bash -eux

useradd --create-home --shell /bin/bash --uid 1000 --gid users --groups sudo,docker ${BUILDER_USER} && echo "${BUILDER_USER}:${BUILDER_USER}" | chpasswd
echo "${BUILDER_USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
visudo -c

cp /root/.bashrc /home/${BUILDER_USER}/.bashrc

# Git 
git config --global user.email "info@noroutine.me"
git config --global user.name "Git Robot"
git config --global http.proxy ${HTTP_PROXY:-http://proxy.bo01.noroutine.me:3128}

cp /root/.gitconfig /home/${BUILDER_USER}/.gitconfig