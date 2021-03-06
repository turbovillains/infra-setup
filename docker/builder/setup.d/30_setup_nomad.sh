#!/usr/bin/env bash -eux

NOMAD_VERSION=${NOMAD_VERSION:-1.0.4}
NOMAD_URL=https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip
NOMAD_SHA256=dbb8b8b1366c8ea9504cc396f2c00a254e043b1fc9f39f39d9ef3398e454e840
NOMAD_TARGET=/usr/local/bin/nomad

NOMAD_ZIP=$(mktemp --tmpdir=/tmp nomad.XXXXXXXXX.zip)
curl -s -o ${NOMAD_ZIP} ${NOMAD_URL}

sha256sum ${NOMAD_ZIP} | grep ${NOMAD_SHA256}

unzip -p ${NOMAD_ZIP} > ${NOMAD_TARGET} && chmod +x ${NOMAD_TARGET}

rm -f ${NOMAD_ZIP}

# End of file