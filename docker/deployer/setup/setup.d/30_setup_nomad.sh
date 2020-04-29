#!/usr/bin/env bash -eux

NOMAD_VERSION=${NOMAD_VERSION:-0.9.6}
NOMAD_URL=https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip
NOMAD_SHA256=063047c245442674d2e9287fc37a5a369312a3f5ca4c6954036a64039c7adde1
NOMAD_TARGET=/usr/local/bin/nomad

NOMAD_ZIP=$(mktemp --tmpdir=/tmp nomad.XXXXXXXXX.zip)
curl -s -o ${NOMAD_ZIP} ${NOMAD_URL}

sha256sum ${NOMAD_ZIP} | grep ${NOMAD_SHA256}

unzip -p ${NOMAD_ZIP} > ${NOMAD_TARGET} && chmod +x ${NOMAD_TARGET}

rm -f ${NOMAD_ZIP}

# End of file