ARG IMAGE_REGISTRY
ARG INFRA_NAMESPACE
ARG INFRA_VERSION
ARG PYTHON_VERSION

FROM ${IMAGE_REGISTRY}/${INFRA_NAMESPACE}/noroutine-ca:${INFRA_VERSION} AS rootca

FROM ${IMAGE_REGISTRY}/library/python:${PYTHON_VERSION}

# full bundle of CA certs set from Mozilla + Noroutine CA certs
RUN apt-get update && \
  apt-get -y install ca-certificates && \
  apt-get clean && \
  apt-get autoremove -y && \
  rm -rf /var/cache/apt/* && \
  rm -rf /var/lib/apt/lists/*

COPY --from=rootca /noroutine /usr/local/share/ca-certificates/noroutine
RUN update-ca-certificates
