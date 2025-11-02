ARG IMAGE_REGISTRY
ARG DEBIAN_VERSION
ARG INFRA_NAMESPACE
ARG INFRA_VERSION

FROM ${IMAGE_REGISTRY}/${INFRA_NAMESPACE}/noroutine-ca:${INFRA_VERSION} AS rootca

FROM ${IMAGE_REGISTRY}/library/debian:${DEBIAN_VERSION} AS download

RUN apt-get update && apt-get install -y \
    curl ca-certificates unzip zstd curl \
  && rm -rf /var/lib/apt/lists/*

COPY --from=rootca /noroutine /usr/local/share/ca-certificates/noroutine
RUN update-ca-certificates

USER 0

ADD setup.sh /setup.sh
RUN /setup.sh

FROM scratch

COPY --from=download /usr/local/bin /usr/local/bin
