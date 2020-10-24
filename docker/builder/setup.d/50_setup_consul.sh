#!/usr/bin/env bash -eux

CONSUL_VERSION=${CONSUL_VERSION:-1.8.4}
CONSUL_URL=https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip
CONSUL_SHA256=0d74525ee101254f1cca436356e8aee51247d460b56fc2b4f7faef8a6853141f
CONSUL_TARGET=/usr/local/bin/consul

CONSUL_ZIP=$(mktemp --tmpdir=/tmp consul.XXXXXXXXX.zip)
curl -s -o ${CONSUL_ZIP} ${CONSUL_URL}

sha256sum ${CONSUL_ZIP} | grep ${CONSUL_SHA256}

unzip -p ${CONSUL_ZIP} > ${CONSUL_TARGET} && chmod +x ${CONSUL_TARGET}

rm -f ${CONSUL_ZIP}

# End of file