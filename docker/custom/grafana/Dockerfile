ARG IMAGE_REGISTRY=cr.nrtn.dev
ARG INFRA_NAMESPACE=infra-dev
ARG INFRA_VERSION=dev
ARG GRAFANA_VERSION=dev

# FROM ${IMAGE_REGISTRY}/${INFRA_NAMESPACE}/grafana-dashboards:${INFRA_VERSION} as dashboards

FROM ${IMAGE_REGISTRY}/grafana/grafana:${GRAFANA_VERSION}

ADD setup.sh /opt/grafana/setup.sh
RUN /opt/grafana/setup.sh

# COPY --from=dashboards /dashboards /opt/grafana/dashboard-sets
# COPY ./provisioning/gf-dashboard-set.yml ${GF_PATHS_PROVISIONING}/dashboards/gf-dashboard-set.yml
