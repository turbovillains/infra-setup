ARG DOCKER_HUB
ARG INFRA_VERSION
ARG BITNAMI_GRAFANA_VERSION

FROM ${DOCKER_HUB}/infra/noroutine-ca:${INFRA_VERSION} as rootca

# FROM node:18-alpine3.15 as mqtt_datasource_build

# RUN apk add --no-cache git make musl-dev go

# # Configure Go
# ENV GOROOT=/usr/lib/go \
#   GOPATH=/go \
#   PATH=/go/bin:${PATH}

# RUN mkdir -p ${GOPATH}/src ${GOPATH}/bin

# RUN go get -u github.com/grafana/grafana-plugin-sdk-go

# RUN git clone https://github.com/grafana/mqtt-datasource.git \
#   && cd mqtt-datasource \
#   && go mod tidy \
#   && export NODE_OPTIONS="--openssl-legacy-provider" \
#   && yarn install \
#   && yarn build

FROM ${DOCKER_HUB}/infra/grafana-dashboards:${INFRA_VERSION} as dashboards

FROM ${DOCKER_HUB}/bitnami/grafana:${BITNAMI_GRAFANA_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.me>"

# full bundle of CA certs set from Mozilla + Noroutine CA certs
USER 0
COPY --from=rootca /noroutine /usr/local/share/ca-certificates/noroutine
RUN update-ca-certificates

ADD setup.sh /opt/bitnami/grafana/setup.sh
RUN /opt/bitnami/grafana/setup.sh

COPY --from=dashboards /dashboards /opt/bitnami/grafana/dashboard-sets
COPY ./provisioning/gf-dashboard-set.yml ${GF_PATHS_PROVISIONING}/dashboards/gf-dashboard-set.yml

# COPY --from=mqtt_datasource_build /mqtt-datasource/ /opt/bitnami/grafana/data/plugins/mqtt-datasource

RUN chown -R 1001:1001 /opt/bitnami/grafana/data /opt/bitnami/grafana/logs

USER 1001
