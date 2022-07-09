ARG DOCKER_HUB
ARG INFRA_VERSION
ARG DOCKER_REGISTRY_VERSION

FROM ${DOCKER_HUB}/infra/noroutine-ca:${INFRA_VERSION} as rootca

FROM ${DOCKER_HUB}/registry:${DOCKER_REGISTRY_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"

# full bundle of CA certs set from Mozilla + Noroutine CA certs
USER 0
COPY --from=rootca /noroutine /usr/local/share/ca-certificates/noroutine
RUN update-ca-certificates
