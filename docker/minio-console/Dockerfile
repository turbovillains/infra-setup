ARG DOCKER_HUB
ARG INFRA_VERSION
ARG MINIO_CONSOLE_VERSION

FROM ${DOCKER_HUB}/infra/noroutine-ca:${INFRA_VERSION} as rootca

FROM ${DOCKER_HUB}/minio/console:${MINIO_CONSOLE_VERSION} as upstream

FROM ${DOCKER_HUB}/infra/debian:${INFRA_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"

COPY --from=upstream /console /console

EXPOSE 9090

ENTRYPOINT ["/console"]
