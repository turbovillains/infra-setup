ARG DOCKER_HUB
ARG INFRA_VERSION
ARG INFRA_NAMESPACE
ARG DISTROLESS_VERSION
ARG FLAVOUR

FROM ${DOCKER_HUB}/${INFRA_NAMESPACE}/noroutine-ca:${INFRA_VERSION} as rootca

FROM ${DOCKER_HUB}/distroless/${FLAVOUR}-${DISTROLESS_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"

COPY --from=rootca /noroutine /usr/local/share/ca-certificates/noroutine
COPY --from=rootca /ca-certificates.crt /etc/ssl/certs/ca-certificates.crt

# TODO: RUN [ "update-ca-certificates" ]
