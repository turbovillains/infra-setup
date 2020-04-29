#!/usr/bin/env bash -eux

VAULT_VERSION=${VAULT_VERSION:-1.2.3}
VAULT_URL=https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip
VAULT_SHA256=fe15676404aff35cb45f7c957f90491921b9269d79a8f933c5a36e26a431bfc4
VAULT_TARGET=/usr/local/bin/vault

VAULT_ZIP=$(mktemp --tmpdir=/tmp vault.XXXXXXXXX.zip)
curl -s -o ${VAULT_ZIP} ${VAULT_URL}

sha256sum ${VAULT_ZIP} | grep ${VAULT_SHA256}

unzip -p ${VAULT_ZIP} > ${VAULT_TARGET} && chmod +x ${VAULT_TARGET}

rm -f ${VAULT_ZIP}

# End of file