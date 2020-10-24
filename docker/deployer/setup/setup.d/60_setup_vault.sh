#!/usr/bin/env bash -eux

VAULT_VERSION=${VAULT_VERSION:-1.5.5}
VAULT_URL=https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip
VAULT_SHA256=2a6958e6c8d6566d8d529fe5ef9378534903305d0f00744d526232d1c860e1ed
VAULT_TARGET=/usr/local/bin/vault

VAULT_ZIP=$(mktemp --tmpdir=/tmp vault.XXXXXXXXX.zip)
curl -s -o ${VAULT_ZIP} ${VAULT_URL}

sha256sum ${VAULT_ZIP} | grep ${VAULT_SHA256}

unzip -p ${VAULT_ZIP} > ${VAULT_TARGET} && chmod +x ${VAULT_TARGET}

rm -f ${VAULT_ZIP}

# End of file