ARG DOCKER_HUB
ARG INFRA_VERSION
ARG BUILDPACKSIO_LIFECYCLE_VERSION

FROM ${DOCKER_HUB}/infra/noroutine-ca:${INFRA_VERSION} as rootca

FROM ${DOCKER_HUB}/buildpacksio/lifecycle:${BUILDPACKSIO_LIFECYCLE_VERSION}

MAINTAINER Noroutine GmbH <info@noroutine.me>

# full bundle of CA certs set from Mozilla + Noroutine CA certs
COPY --from=rootca /ca-certificates.crt /etc/ssl/certs/ca-certificates.crt