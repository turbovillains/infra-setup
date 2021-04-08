#!/usr/bin/env bash -eux

curl -sL -o /usr/local/bin/cfssl https://github.com/cloudflare/cfssl/releases/download/v1.5.0/cfssl_1.5.0_linux_amd64
chmod +x /usr/local/bin/cfssl
cfssl version