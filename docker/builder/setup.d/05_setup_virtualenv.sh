#!/usr/bin/env bash -eux

export VIRTUAL_ENV_DISABLE_PROMPT=true

virtualenv -p python3 /root/.py3
virtualenv -p python3 /home/builder/.py3

. /root/.py3/bin/activate

pip install --upgrade pip
pip install ansible
pip install nexus3-cli

python -V | egrep '^Python 3'   # fail on python 2

. /home/builder/.py3/bin/activate

pip install --upgrade pip
pip install ansible
pip install nexus3-cli

python -V | egrep '^Python 3'   # fail on python 2

# makes python requests library stop complaining about SSL errors
export REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt

mkdir -p /root/.ansible /home/builder/.ansible
echo 123234345 | tee /root/.ansible/vault-password | tee /home/builder/.ansible/vault-password

cat <<'EOF' | tee -a /root/.bashrc | tee -a /home/builder/.bashrc

# Python
[ -s "${HOME}/.py3/bin/activate" ] && \. "${HOME}/.py3/bin/activate"  # This loads py3
export REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
EOF