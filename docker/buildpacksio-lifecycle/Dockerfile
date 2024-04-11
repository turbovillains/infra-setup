ARG DOCKER_HUB
ARG INFRA_VERSION
ARG INFRA_NAMESPACE
ARG BUILDPACKSIO_LIFECYCLE_VERSION

FROM ${DOCKER_HUB}/${INFRA_NAMESPACE}/noroutine-ca:${INFRA_VERSION} as rootca

FROM ${DOCKER_HUB}/buildpacksio/lifecycle:${BUILDPACKSIO_LIFECYCLE_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"

# full bundle of CA certs set from Mozilla + Noroutine CA certs
COPY --from=rootca /ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=rootca /noroutine /usr/local/share/ca-certificates/noroutine
# RUN update-ca-certificates
