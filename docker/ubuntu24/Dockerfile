ARG IMAGE_REGISTRY
ARG UBUNTU_NOBLE_VERSION
ARG INFRA_VERSION
ARG INFRA_NAMESPACE

FROM ${IMAGE_REGISTRY}/${INFRA_NAMESPACE}/noroutine-ca:${INFRA_VERSION} AS rootca

FROM ${IMAGE_REGISTRY}/library/ubuntu:${UBUNTU_NOBLE_VERSION}

RUN apt-get update && apt-get install -y \
    curl ca-certificates \
  && rm -rf /var/lib/apt/lists/*

COPY --from=rootca /noroutine /usr/local/share/ca-certificates/noroutine
RUN update-ca-certificates
