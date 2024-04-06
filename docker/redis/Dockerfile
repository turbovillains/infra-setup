ARG DOCKER_HUB
ARG INFRA_VERSION
ARG REDIS_VERSION

FROM ${DOCKER_HUB}/infra/noroutine-ca:${INFRA_VERSION} as rootca

FROM ${DOCKER_HUB}/library/redis:${REDIS_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"

# full bundle of CA certs set from Mozilla + Noroutine CA certs
USER 0
RUN apt-get update && \
  apt-get -y install ca-certificates && \
  apt-get clean && \
  apt-get autoremove -y && \
  rm -rf /var/cache/apt/* && \
  rm -rf /var/lib/apt/lists/*

COPY --from=rootca /noroutine /usr/local/share/ca-certificates/noroutine
RUN update-ca-certificates
