ARG IMAGE_REGISTRY=cr.nrtn.dev
ARG INFRA_NAMESPACE=infra-dev
ARG INFRA_VERSION=dev
ARG AIRFLOW_VERSION=dev

FROM ${IMAGE_REGISTRY}/${INFRA_NAMESPACE}/noroutine-ca:${INFRA_VERSION} AS rootca

FROM ${IMAGE_REGISTRY}/apache/airflow:${AIRFLOW_VERSION}

USER 0

# MySQL

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A8D3785C
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 467B942D3A79BD29

RUN apt-get update && apt-get install -y \
    curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY --from=rootca /noroutine /usr/local/share/ca-certificates/noroutine
RUN update-ca-certificates

USER ${AIRFLOW_UID}
