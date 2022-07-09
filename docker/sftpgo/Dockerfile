ARG DOCKER_HUB
ARG SFTPGO_VERSION
ARG INFRA_VERSION

FROM ${DOCKER_HUB}/infra/noroutine-ca:${INFRA_VERSION} as rootca

FROM ${DOCKER_HUB}/drakkan/sftpgo:${SFTPGO_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"

USER 0
# full bundle of CA certs set from Mozilla + Noroutine CA certs
COPY --from=rootca /noroutine /usr/local/share/ca-certificates/noroutine
RUN update-ca-certificates

USER sftpgo