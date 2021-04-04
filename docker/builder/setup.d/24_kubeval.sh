#!/usr/bin/env bash -eux

curl -sLo- https://github.com/instrumenta/kubeval/releases/latest/download/kubeval-linux-amd64.tar.gz | tar -C /usr/local/bin -zxv kubeval 
chmod 0755 /usr/local/bin/kubeval