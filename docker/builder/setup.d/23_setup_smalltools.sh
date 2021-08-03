#!/usr/bin/env bash -eux

mkdir -p /root/.pack /home/${BUILDER_USER}/.pack
cat <<EOF | tee /root/.pack/config.toml | tee /home/${BUILDER_USER}/.pack/config.toml
default-builder-image = "${DOCKER_HUB}/heroku/buildpacks:${BUILDPACKS_VERSION}"
lifecycle-image = "${DOCKER_HUB}/infra/buildpacksio-lifecycle:${BUILDPACKS_VERSION}"

[[trusted-builders]]
  name = "${DOCKER_HUB}/heroku/buildpacks:${BUILDPACKS_VERSION}"

[[trusted-builders]]
  name = "${DOCKER_HUB}/heroku/spring-boot-buildpacks:${BUILDPACKS_VERSION}"

[[trusted-builders]]
  name = "${DOCKER_HUB}/paketobuildpacks/builder:full"

[[trusted-builders]]
  name = "${DOCKER_HUB}/paketobuildpacks/builder:tiny"
EOF

# ttyd
curl -sLo /usr/local/bin/ttyd https://github.com/tsl0922/ttyd/releases/download/1.6.3/ttyd.x86_64

chmod +x /usr/local/bin/*