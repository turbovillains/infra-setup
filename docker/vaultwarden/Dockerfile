ARG DOCKER_HUB
ARG VAULTWARDEN_VERSION
ARG INFRA_VERSION
ARG INFRA_NAMESPACE

FROM ${DOCKER_HUB}/${INFRA_NAMESPACE}/noroutine-ca:${INFRA_VERSION} as rootca

FROM ${DOCKER_HUB}/vaultwarden/server:${VAULTWARDEN_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"

# USER 0
RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y ca-certificates && \
  apt-get clean && rm -rf /var/lib/apt/lists/*

# full bundle of CA certs set from Mozilla + Noroutine CA certs
COPY --from=rootca /noroutine /usr/local/share/ca-certificates/noroutine
RUN /usr/sbin/update-ca-certificates
