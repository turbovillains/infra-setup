#!/usr/bin/env bash -eux

curl -sL -o /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/v4.7.0/yq_linux_amd64
shasum -a 256 /usr/local/bin/yq | grep ec857c8240fda5782c3dd75b54b93196fa496a9bcf7c76979bb192b38f76da31
chmod +x /usr/local/bin/yq

