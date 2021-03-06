#!/usr/bin/env bash -eux

CONSUL_TEMPLATE_VERSION=${CONSUL_TEMPLATE_VERSION:-0.25.2}
CONSUL_TEMPLATE_URL=https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip
CONSUL_TEMPLATE_SHA256=9edf7cd9dfa0d83cd992e5501a480ea502968f15109aebe9ba2203648f3014db
CONSUL_TEMPLATE_TARGET=/usr/local/bin/consul-template

CONSUL_TEMPLATE_ZIP=$(mktemp --tmpdir=/tmp consul-template.XXXXXXXXX.zip)
curl -s -o ${CONSUL_TEMPLATE_ZIP} ${CONSUL_TEMPLATE_URL}

sha256sum ${CONSUL_TEMPLATE_ZIP} | grep ${CONSUL_TEMPLATE_SHA256}

unzip -p ${CONSUL_TEMPLATE_ZIP} > ${CONSUL_TEMPLATE_TARGET} && chmod +x ${CONSUL_TEMPLATE_TARGET}

rm -f ${CONSUL_TEMPLATE_ZIP}

# End of file