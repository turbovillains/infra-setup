ARG DOCKER_HUB
ARG INFRA_VERSION
ARG BITNAMI_NATS_VERSION

FROM ${DOCKER_HUB}/infra/noroutine-ca:${INFRA_VERSION} as rootca

FROM ${DOCKER_HUB}/bitnami/nats:${BITNAMI_NATS_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.me>"

# full bundle of CA certs set from Mozilla + Noroutine CA certs
COPY --from=rootca /noroutine /usr/local/share/ca-certificates/noroutine
USER 0
RUN /usr/sbin/update-ca-certificates
USER 1001