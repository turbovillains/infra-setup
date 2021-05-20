#!/usr/bin/env bash -eux

ENVCONSUL_VERSION=${ENVCONSUL_VERSION:-0.11.0}
ENVCONSUL_URL=https://releases.hashicorp.com/envconsul/${ENVCONSUL_VERSION}/envconsul_${ENVCONSUL_VERSION}_linux_amd64.zip
ENVCONSUL_SHA256=e52fe2036cacec12b24431044af2c71989c21271ef4d880d3f0e713aee203bc0
ENVCONSUL_TARGET=/usr/local/bin/envconsul

ENVCONSUL_ZIP=$(mktemp --tmpdir=/tmp envconsul.XXXXXXXXX.zip)
curl -sLo ${ENVCONSUL_ZIP} ${ENVCONSUL_URL}

sha256sum ${ENVCONSUL_ZIP} | grep ${ENVCONSUL_SHA256}

unzip -p ${ENVCONSUL_ZIP} > ${ENVCONSUL_TARGET} && chmod +x ${ENVCONSUL_TARGET}

rm -f ${ENVCONSUL_ZIP}

# End of file