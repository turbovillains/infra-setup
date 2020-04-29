#!/usr/bin/env bash -eux

python -V | grep 'Python 3'
ansible --version | grep 'ansible 2'

# TODO: validate certificate authorities are setup correctly

# End of file