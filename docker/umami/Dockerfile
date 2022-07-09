ARG DOCKER_HUB
ARG INFRA_VERSION
ARG UMAMI_VERSION

FROM ${DOCKER_HUB}/infra/noroutine-ca:${INFRA_VERSION} as rootca

FROM ${DOCKER_HUB}/mikecao/umami:${UMAMI_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"
