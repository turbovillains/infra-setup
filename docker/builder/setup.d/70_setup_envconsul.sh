#!/usr/bin/env bash -eux

ENVCONSUL_VERSION=${ENVCONSUL_VERSION:-0.9.0}
ENVCONSUL_URL=https://releases.hashicorp.com/envconsul/${ENVCONSUL_VERSION}/envconsul_${ENVCONSUL_VERSION}_linux_amd64.zip
ENVCONSUL_SHA256=a5743e1e870833275cc2dd890c229b37097e74f6cc9cf5bf4ea62c4bf6ef7e2d
ENVCONSUL_TARGET=/usr/local/bin/envconsul

ENVCONSUL_ZIP=$(mktemp --tmpdir=/tmp envconsul.XXXXXXXXX.zip)
curl -s -o ${ENVCONSUL_ZIP} ${ENVCONSUL_URL}

sha256sum ${ENVCONSUL_ZIP} | grep ${ENVCONSUL_SHA256}

unzip -p ${ENVCONSUL_ZIP} > ${ENVCONSUL_TARGET} && chmod +x ${ENVCONSUL_TARGET}

rm -f ${ENVCONSUL_ZIP}

# End of file