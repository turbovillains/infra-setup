ARG DOCKER_HUB
ARG INFRA_VERSION
ARG DIND_VERSION

FROM ${DOCKER_HUB}/infra/noroutine-ca:${INFRA_VERSION} as rootca

FROM ${DOCKER_HUB}/docker:${DIND_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"

# full bundle of CA certs set from Mozilla + Noroutine CA certs
COPY --from=rootca /noroutine /usr/local/share/ca-certificates
RUN update-ca-certificates
