ARG DOCKER_HUB
ARG INFRA_VERSION
ARG MINIO_CONSOLE_VERSION

FROM ${DOCKER_HUB}/infra/noroutine-ca:${INFRA_VERSION} as rootca

FROM ${DOCKER_HUB}/minio/console:${MINIO_CONSOLE_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"

# Noroutine CA certs
USER 0
COPY --from=rootca /noroutine /usr/local/share/ca-certificates/
RUN update-ca-trust
