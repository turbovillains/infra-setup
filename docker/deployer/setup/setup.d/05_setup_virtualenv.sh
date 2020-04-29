#!/usr/bin/env bash -eux

virtualenv -p python3 ~/.py3

VIRTUAL_ENV_DISABLE_PROMPT=true . ~/.py3/bin/activate

pip install --upgrade pip
pip install ansible