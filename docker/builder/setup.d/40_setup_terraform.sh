#!/usr/bin/env bash -eux

TERRAFORM_VERSION=${TERRAFORM_VERSION:-0.14.7}
TERRAFORM_URL=https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
TERRAFORM_SHA256=6b66e1faf0ad4ece28c42a1877e95bbb1355396231d161d78b8ca8a99accc2d7
TERRAFORM_TARGET=/usr/local/bin/terraform

TERRAFORM_ZIP=$(mktemp --tmpdir=/tmp terraform.XXXXXXXXX.zip)
curl -sLo ${TERRAFORM_ZIP} ${TERRAFORM_URL}

sha256sum ${TERRAFORM_ZIP} | grep ${TERRAFORM_SHA256}

unzip -p ${TERRAFORM_ZIP} > ${TERRAFORM_TARGET} && chmod +x ${TERRAFORM_TARGET}

rm -f ${TERRAFORM_ZIP}

# End of file