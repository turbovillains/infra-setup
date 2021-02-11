#!/usr/bin/env bash -eux

export VIRTUAL_ENV_DISABLE_PROMPT=true

virtualenv -p python3 /root/.py3
virtualenv -p python3 /home/builder/.py3

. /root/.py3/bin/activate

pip install ansible

python -V | egrep '^Python 3'   # fail on python 2

. /home/builder/.py3/bin/activate

pip install ansible

python -V | egrep '^Python 3'   # fail on python 2

# makes python requests library stop complaining about SSL errors
export REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt

mkdir -p /root/.ansible /home/builder/.ansible
echo 123234345 | tee /root/.ansible/vault-password | tee /home/builder/.ansible/vault-password