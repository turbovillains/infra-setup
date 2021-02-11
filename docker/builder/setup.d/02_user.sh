#!/usr/bin/env bash -eux

useradd --create-home --shell /bin/bash --uid 1000 --gid users --groups sudo,docker builder && echo "builder:builder" | chpasswd
echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
visudo -c
