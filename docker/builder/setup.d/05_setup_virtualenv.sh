#!/usr/bin/env bash -eux

export VIRTUAL_ENV_DISABLE_PROMPT=true

virtualenv -p python3 /root/.py3
virtualenv -p python3 /home/${BUILDER_USER}/.py3

. /root/.py3/bin/activate

pip install --upgrade pip
pip install ansible
pip install nexus3-cli

python -V | egrep '^Python 3'   # fail on python 2

. /home/${BUILDER_USER}/.py3/bin/activate

pip install --upgrade pip
pip install ansible
pip install nexus3-cli

python -V | egrep '^Python 3'   # fail on python 2

# makes python requests library stop complaining about SSL errors
export REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt

mkdir -p /root/.ansible /home/${BUILDER_USER}/.ansible
echo 123234345 | tee /root/.ansible/vault-password | tee /home/${BUILDER_USER}/.ansible/vault-password
