#!/usr/bin/env bash -eux

ENVCONSUL_VERSION=${ENVCONSUL_VERSION:-0.10.0}
ENVCONSUL_URL=https://releases.hashicorp.com/envconsul/${ENVCONSUL_VERSION}/envconsul_${ENVCONSUL_VERSION}_linux_amd64.zip
ENVCONSUL_SHA256=ac459fbfaa2cdb259bf27b0c4b83c64a537d22293e8a60d76a053cea7f204eee
ENVCONSUL_TARGET=/usr/local/bin/envconsul

ENVCONSUL_ZIP=$(mktemp --tmpdir=/tmp envconsul.XXXXXXXXX.zip)
curl -s -o ${ENVCONSUL_ZIP} ${ENVCONSUL_URL}

sha256sum ${ENVCONSUL_ZIP} | grep ${ENVCONSUL_SHA256}

unzip -p ${ENVCONSUL_ZIP} > ${ENVCONSUL_TARGET} && chmod +x ${ENVCONSUL_TARGET}

rm -f ${ENVCONSUL_ZIP}

# End of file