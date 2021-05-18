#!/usr/bin/env bash -eux

curl -sLo- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash

rsync -av /root/.nvm/ /home/${BUILDER_USER}/.nvm