#!/usr/bin/env bash -eux

TERRAFORM_VERSION=${TERRAFORM_VERSION:-0.12.18}
TERRAFORM_URL=https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
TERRAFORM_SHA256=e7ebe3ca988768bffe0c239d107645bd53515354cff6cbe5651718195a151700
TERRAFORM_TARGET=/usr/local/bin/terraform

TERRAFORM_ZIP=$(mktemp --tmpdir=/tmp terraform.XXXXXXXXX.zip)
curl -s -o ${TERRAFORM_ZIP} ${TERRAFORM_URL}

sha256sum ${TERRAFORM_ZIP} | grep ${TERRAFORM_SHA256}

unzip -p ${TERRAFORM_ZIP} > ${TERRAFORM_TARGET} && chmod +x ${TERRAFORM_TARGET}

rm -f ${TERRAFORM_ZIP}

# End of file