#!/usr/bin/env bash -eux

export VIRTUAL_ENV_DISABLE_PROMPT=true

virtualenv -p python3 /home/${BUILDER_USER}/.py3

. /home/${BUILDER_USER}/.py3/bin/activate

pip install --upgrade pip
pip install ansible
pip install nexus3-cli

python -V | egrep '^Python 3'   # fail on python 2

# makes python requests library stop complaining about SSL errors
export REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt

mkdir -p /home/${BUILDER_USER}/.ansible
