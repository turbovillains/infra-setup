#!/usr/bin/env bash -eux

NOMAD_VERSION=${NOMAD_VERSION:-0.10.0}
NOMAD_URL=https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip
NOMAD_SHA256=dd9dbe334e36e15c6f659c52d2722743f6632674fc9ffb42774378eb8ee1747f
NOMAD_TARGET=/usr/local/bin/nomad

NOMAD_ZIP=$(mktemp --tmpdir=/tmp nomad.XXXXXXXXX.zip)
curl -s -o ${NOMAD_ZIP} ${NOMAD_URL}

sha256sum ${NOMAD_ZIP} | grep ${NOMAD_SHA256}

unzip -p ${NOMAD_ZIP} > ${NOMAD_TARGET} && chmod +x ${NOMAD_TARGET}

rm -f ${NOMAD_ZIP}

# End of file