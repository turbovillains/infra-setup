ARG IMAGE_REGISTRY=cr.noroutine.me
ARG GRAFANA_VERSION=dev

FROM ${IMAGE_REGISTRY}/grafana/grafana:${GRAFANA_VERSION}

ADD setup.sh /opt/grafana/setup.sh
RUN /opt/grafana/setup.sh
