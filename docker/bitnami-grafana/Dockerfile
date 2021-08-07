ARG DOCKER_HUB
ARG INFRA_VERSION
ARG BITNAMI_GRAFANA_VERSION

FROM ${DOCKER_HUB}/infra/noroutine-ca:${INFRA_VERSION} as rootca

FROM ${DOCKER_HUB}/bitnami/grafana:${BITNAMI_GRAFANA_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.me>"

# full bundle of CA certs set from Mozilla + Noroutine CA certs
USER 0
COPY --from=rootca /noroutine /usr/local/share/ca-certificates/noroutine
RUN update-ca-certificates
USER 1001