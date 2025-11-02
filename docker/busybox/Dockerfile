ARG IMAGE_REGISTRY
ARG INFRA_VERSION
ARG INFRA_NAMESPACE
ARG ALPINE_VERSION
ARG BUSYBOX_VERSION

FROM ${IMAGE_REGISTRY}/${INFRA_NAMESPACE}/noroutine-ca:${INFRA_VERSION} AS rootca

FROM ${IMAGE_REGISTRY}/library/alpine:${ALPINE_VERSION} AS alpine

RUN apk update && apk add ca-certificates && rm -rf /var/cache/apk/*

USER 0
COPY --from=rootca /noroutine /usr/local/share/ca-certificates/noroutine
RUN update-ca-certificates

FROM ${IMAGE_REGISTRY}/library/busybox:${BUSYBOX_VERSION}

COPY --from=alpine /etc/ssl/certs /etc/ssl/certs
