ARG DOCKER_HUB
ARG KEEWEB_VERSION
ARG INFRA_VERSION

FROM ${DOCKER_HUB}/infra/noroutine-ca:${INFRA_VERSION} as rootca

FROM ${DOCKER_HUB}/antelle/keeweb:${KEEWEB_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"
