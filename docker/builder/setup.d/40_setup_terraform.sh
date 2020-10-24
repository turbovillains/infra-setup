#!/usr/bin/env bash -eux

TERRAFORM_VERSION=${TERRAFORM_VERSION:-0.13.5}
TERRAFORM_URL=https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
TERRAFORM_SHA256=f7b7a7b1bfbf5d78151cfe3d1d463140b5fd6a354e71a7de2b5644e652ca5147
TERRAFORM_TARGET=/usr/local/bin/terraform

TERRAFORM_ZIP=$(mktemp --tmpdir=/tmp terraform.XXXXXXXXX.zip)
curl -s -o ${TERRAFORM_ZIP} ${TERRAFORM_URL}

sha256sum ${TERRAFORM_ZIP} | grep ${TERRAFORM_SHA256}

unzip -p ${TERRAFORM_ZIP} > ${TERRAFORM_TARGET} && chmod +x ${TERRAFORM_TARGET}

rm -f ${TERRAFORM_ZIP}

# End of file