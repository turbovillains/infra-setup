#!/usr/bin/env bash -eux

VAULT_VERSION=${VAULT_VERSION:-1.6.3}
VAULT_URL=https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip
VAULT_SHA256=844adaf632391be41f945143de7dccfa9b39c52a72e8e22a5d6bad9c32404c46
VAULT_TARGET=/usr/local/bin/vault

VAULT_ZIP=$(mktemp --tmpdir=/tmp vault.XXXXXXXXX.zip)
curl -sLo ${VAULT_ZIP} ${VAULT_URL}

sha256sum ${VAULT_ZIP} | grep ${VAULT_SHA256}

unzip -p ${VAULT_ZIP} > ${VAULT_TARGET} && chmod +x ${VAULT_TARGET}

rm -f ${VAULT_ZIP}

# End of file