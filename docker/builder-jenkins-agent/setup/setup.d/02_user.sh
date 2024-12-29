#!/usr/bin/env bash -eux

# in base image user is already created with uid 1000 and gid 1000
usermod --groups users,sudo,docker ${BUILDER_USER}
echo "${BUILDER_USER}:${BUILDER_USER}" | chpasswd
echo "${BUILDER_USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
visudo -c

cp /setup/dotprofile/.bashrc /home/${BUILDER_USER}/.bashrc
cp /setup/dotprofile/.bashrc /root/.bashrc

# Git
git config --global user.email "info@noroutine.com"
git config --global user.name "Builder 3000"

cp /root/.gitconfig /home/${BUILDER_USER}/.gitconfig

echo "PATH=${PATH}" >> /etc/environment
