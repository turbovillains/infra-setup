ARG DOCKER_HUB
ARG INFRA_VERSION
ARG INFRA_NAMESPACE

FROM ${DOCKER_HUB}/${INFRA_NAMESPACE}/noroutine-ca:${INFRA_VERSION} as rootca

FROM ${DOCKER_HUB}/${INFRA_NAMESPACE}/ubuntu24:${INFRA_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"

# full bundle of CA certs set from Mozilla + Noroutine CA certs, setup will run the update
RUN apt-get update && apt-get install -y \
    curl ca-certificates \
  && rm -rf /var/lib/apt/lists/*

COPY --from=rootca /noroutine /usr/local/share/ca-certificates/noroutine
RUN update-ca-certificates

RUN --mount=target=/build /build/setup.sh

# https://github.com/buildpacks/spec/blob/platform/0.13/platform.md#run-image
USER heroku
LABEL io.buildpacks.base.distro.name="ubuntu"
LABEL io.buildpacks.base.distro.version="24.04"
LABEL io.buildpacks.base.homepage="https://github.com/heroku/base-images"
LABEL io.buildpacks.base.maintainer="Noroutine"

# Stack IDs are deprecated, but we still set this for backwards compatibility:
# https://github.com/buildpacks/spec/blob/platform/0.13/platform.md#iobuildpacksstack-labels
LABEL io.buildpacks.stack.id="heroku-24"
