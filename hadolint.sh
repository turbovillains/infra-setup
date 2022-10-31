#!/bin/bash

for dockerfile in docker/*/Dockerfile; do
  docker run --rm -i cr.nrtn.dev/infra/hadolint:${INFRA_VERSION} < ${dockerfile};
done
