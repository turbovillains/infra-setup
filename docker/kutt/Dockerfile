ARG DOCKER_HUB
ARG INFRA_VERSION
ARG KUTT_VERSION

FROM ${DOCKER_HUB}/infra/noroutine-ca:${INFRA_VERSION} as rootca

FROM ${DOCKER_HUB}/kutt/kutt:${KUTT_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.me>"

# full bundle of CA certs set from Mozilla + Noroutine CA certs
# COPY --from=rootca /noroutine /usr/local/share/ca-certificates/noroutine
# RUN update-ca-certificates
