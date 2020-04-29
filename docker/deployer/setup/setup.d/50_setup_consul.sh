#!/usr/bin/env bash -eux

CONSUL_VERSION=${CONSUL_VERSION:-1.6.1}
CONSUL_URL=https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip
CONSUL_SHA256=a8568ca7b6797030b2c32615b4786d4cc75ce7aee2ed9025996fe92b07b31f7e
CONSUL_TARGET=/usr/local/bin/consul

CONSUL_ZIP=$(mktemp --tmpdir=/tmp consul.XXXXXXXXX.zip)
curl -s -o ${CONSUL_ZIP} ${CONSUL_URL}

sha256sum ${CONSUL_ZIP} | grep ${CONSUL_SHA256}

unzip -p ${CONSUL_ZIP} > ${CONSUL_TARGET} && chmod +x ${CONSUL_TARGET}

rm -f ${CONSUL_ZIP}

# End of file