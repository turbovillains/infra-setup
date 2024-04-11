ARG DOCKER_HUB
ARG INFRA_VERSION
ARG INFRA_NAMESPACE
ARG ALPINE_VERSION
ARG BUSYBOX_VERSION

FROM ${DOCKER_HUB}/${INFRA_NAMESPACE}/noroutine-ca:${INFRA_VERSION} as rootca

FROM ${DOCKER_HUB}/library/alpine:${ALPINE_VERSION} as alpine

RUN apk update && apk add ca-certificates && rm -rf /var/cache/apk/*

USER 0
COPY --from=rootca /noroutine /usr/local/share/ca-certificates/noroutine
RUN update-ca-certificates

FROM ${DOCKER_HUB}/library/busybox:${BUSYBOX_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"
COPY --from=alpine /etc/ssl/certs /etc/ssl/certs
