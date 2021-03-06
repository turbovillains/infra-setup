#!/usr/bin/env bash -eux

CONSUL_VERSION=${CONSUL_VERSION:-1.9.3}
CONSUL_URL=https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip
CONSUL_SHA256=2ec9203bf370ae332f6584f4decc2f25097ec9ef63852cd4ef58fdd27a313577
CONSUL_TARGET=/usr/local/bin/consul

CONSUL_ZIP=$(mktemp --tmpdir=/tmp consul.XXXXXXXXX.zip)
curl -s -o ${CONSUL_ZIP} ${CONSUL_URL}

sha256sum ${CONSUL_ZIP} | grep ${CONSUL_SHA256}

unzip -p ${CONSUL_ZIP} > ${CONSUL_TARGET} && chmod +x ${CONSUL_TARGET}

rm -f ${CONSUL_ZIP}

# End of file