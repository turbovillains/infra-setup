#!/usr/bin/env bash -eux

mkdir -p /root/.pack /home/${BUILDER_USER}/.pack
cat <<EOF | tee /root/.pack/config.toml | tee /home/${BUILDER_USER}/.pack/config.toml
default-builder-image = "${DOCKER_HUB}/infra/buildpacks:${BUILDPACKS_VERSION}"
lifecycle-image = "${DOCKER_HUB}/infra/buildpacksio-lifecycle:${BUILDPACKS_VERSION}"

[[trusted-builders]]
  name = "${DOCKER_HUB}/infra/buildpacks:${BUILDPACKS_VERSION}"

# [[trusted-builders]]
#   name = "${DOCKER_HUB}/infra/spring-boot-buildpacks:${BUILDPACKS_VERSION}"

# [[trusted-builders]]
#   name = "${DOCKER_HUB}/paketobuildpacks/builder:full"

# [[trusted-builders]]
#   name = "${DOCKER_HUB}/paketobuildpacks/builder:tiny"
EOF
