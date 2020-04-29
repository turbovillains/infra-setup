#!/usr/bin/env bash -eux

TERRAFORM_VERSION=${TERRAFORM_VERSION:-0.12.23}
TERRAFORM_URL=https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
TERRAFORM_SHA256=78fd53c0fffd657ee0ab5decac604b0dea2e6c0d4199a9f27db53f081d831a45
TERRAFORM_TARGET=/usr/local/bin/terraform

TERRAFORM_ZIP=$(mktemp --tmpdir=/tmp terraform.XXXXXXXXX.zip)
curl -s -o ${TERRAFORM_ZIP} ${TERRAFORM_URL}

sha256sum ${TERRAFORM_ZIP} | grep ${TERRAFORM_SHA256}

unzip -p ${TERRAFORM_ZIP} > ${TERRAFORM_TARGET} && chmod +x ${TERRAFORM_TARGET}

rm -f ${TERRAFORM_ZIP}

# End of file