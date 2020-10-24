#!/usr/bin/env bash -eux

NOMAD_VERSION=${NOMAD_VERSION:-0.12.7}
NOMAD_URL=https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip
NOMAD_SHA256=748e543118b9c802205316129ecfd2e2204bccb1193019add68685c56d0cae9b
NOMAD_TARGET=/usr/local/bin/nomad

NOMAD_ZIP=$(mktemp --tmpdir=/tmp nomad.XXXXXXXXX.zip)
curl -s -o ${NOMAD_ZIP} ${NOMAD_URL}

sha256sum ${NOMAD_ZIP} | grep ${NOMAD_SHA256}

unzip -p ${NOMAD_ZIP} > ${NOMAD_TARGET} && chmod +x ${NOMAD_TARGET}

rm -f ${NOMAD_ZIP}

# End of file