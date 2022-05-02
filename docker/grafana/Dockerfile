ARG DOCKER_HUB
ARG GRAFANA_VERSION
ARG DEBIAN_VERSION

# Dashboards
FROM ${DOCKER_HUB}/debian:${DEBIAN_VERSION} as dashboards
ARG GRIT_VERSION

RUN apt-get update && apt-get install -yyq git gnupg2 curl python3 python3-pip && \
  rm -rf /var/lib/apt/lists/*

ADD dashboards /app/dashboards

WORKDIR /app

RUN python3 -V && python3 -m pip install git+https://github.com/noroutine/grit.git@${GRIT_VERSION}
RUN python3 -m grit generate --module dashboards --out 'out/{environment}' --var 'environment=*'

FROM ${DOCKER_HUB}/grafana/grafana:${GRAFANA_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.me>"

ADD setup.sh /opt/grafana/setup.sh
RUN /opt/grafana/setup.sh

COPY --from=dashboards /app/out /opt/grafana/dashboards
COPY ./provisioning/gf-dashboards-set.yml ${GF_PATHS_PROVISIONING}/dashboards/gf-dashboards-set.yml