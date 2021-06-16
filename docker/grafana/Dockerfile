ARG DOCKER_HUB
ARG GRAFANA_VERSION
ARG HTTP_PROY
ARG NO_PROXY
FROM ${DOCKER_HUB}/grafana/grafana:${GRAFANA_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.me>"

ENV HTTP_PROXY=${HTTP_PROXY}
ENV http_proxy=${HTTP_PROXY}
ENV NO_PROXY=${NO_PROXY}
ENV no_proxy=${NO_PROXY}

# RUN grafana-cli plugins install grafana-clock-panel
RUN grafana-cli plugins install vonage-status-panel
RUN grafana-cli plugins install flant-statusmap-panel
RUN grafana-cli plugins install jdbranham-diagram-panel