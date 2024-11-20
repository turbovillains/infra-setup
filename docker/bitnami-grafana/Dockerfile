ARG DOCKER_HUB
ARG INFRA_VERSION
ARG INFRA_NAMESPACE
ARG BITNAMI_GRAFANA_VERSION

FROM ${DOCKER_HUB}/${INFRA_NAMESPACE}/noroutine-ca:${INFRA_VERSION} AS rootca

# FROM ${DOCKER_HUB}/${INFRA_NAMESPACE}/grafana-dashboards:${INFRA_VERSION} AS dashboards

FROM ${DOCKER_HUB}/bitnami/grafana:${BITNAMI_GRAFANA_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"

# full bundle of CA certs set from Mozilla + Noroutine CA certs
USER 0
COPY --from=rootca /noroutine /usr/local/share/ca-certificates/noroutine
RUN update-ca-certificates

ADD setup.sh /opt/bitnami/grafana/setup.sh
RUN /opt/bitnami/grafana/setup.sh

# COPY --from=dashboards /dashboards /opt/bitnami/grafana/dashboard-sets
# COPY ./provisioning/gf-dashboard-set.yml ${GF_PATHS_PROVISIONING}/dashboards/gf-dashboard-set.yml

# COPY --from=mqtt_datasource_build /mqtt-datasource/ /opt/bitnami/grafana/data/plugins/mqtt-datasource

RUN chown -R 1001:1001 /opt/bitnami/grafana/data /opt/bitnami/grafana/logs

USER 1001
