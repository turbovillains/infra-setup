ARG DOCKER_HUB
ARG GRAFANA_VERSION
ARG INFRA_VERSION

FROM ${DOCKER_HUB}/infra/grafana-dashboards:${INFRA_VERSION} as dashboards

FROM ${DOCKER_HUB}/grafana/grafana:${GRAFANA_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"

ADD setup.sh /opt/grafana/setup.sh
RUN /opt/grafana/setup.sh

COPY --from=dashboards /dashboards /opt/grafana/dashboard-sets
COPY ./provisioning/gf-dashboard-set.yml ${GF_PATHS_PROVISIONING}/dashboards/gf-dashboard-set.yml