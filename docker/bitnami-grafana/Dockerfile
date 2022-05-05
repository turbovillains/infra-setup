ARG DOCKER_HUB
ARG INFRA_VERSION
ARG BITNAMI_GRAFANA_VERSION

FROM ${DOCKER_HUB}/infra/noroutine-ca:${INFRA_VERSION} as rootca

FROM ${DOCKER_HUB}/infra/grafana-dashboards:${INFRA_VERSION} as dashboards

FROM ${DOCKER_HUB}/bitnami/grafana:${BITNAMI_GRAFANA_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.me>"

# full bundle of CA certs set from Mozilla + Noroutine CA certs
USER 0
COPY --from=rootca /noroutine /usr/local/share/ca-certificates/noroutine
RUN update-ca-certificates

ADD setup.sh /opt/bitnami/grafana/setup.sh
RUN /opt/bitnami/grafana/setup.sh

COPY --from=dashboards /dashboards /opt/bitnami/grafana/dashboards
COPY ./provisioning/gf-dashboards-set.yml ${GF_PATHS_PROVISIONING}/dashboards/gf-dashboards-set.yml

RUN chown -R 1001:1001 /opt/bitnami/grafana/data /opt/bitnami/grafana/logs

USER 1001
