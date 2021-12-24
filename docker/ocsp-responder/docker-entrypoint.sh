#!/bin/bash -eux

curl -sL -O https://nexus.nrtn.dev/repository/noroutine-ca/noroutine-trusted-ca.index.txt
curl -sL -O https://nexus.nrtn.dev/repository/noroutine-ca/noroutine-ca-bundle.pem

openssl ocsp -port ${OCSP_PORT} -CA noroutine-ca-bundle.pem -index noroutine-trusted-ca.index.txt -rsigner ${OCSP_RSIGNER_CERT} -rkey ${OCSP_RSIGNER_KEY}