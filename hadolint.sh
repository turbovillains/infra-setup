#!/bin/bash

for dockerfile in docker/*/Dockerfile; do
  docker run --rm -i cr.noroutine.me/infra/hadolint:${INFRA_VERSION} < ${dockerfile};
done
