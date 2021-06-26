ARG DOCKER_HUB
ARG INFRA_VERSION
ARG BITNAMI_SHELL_VERSION

FROM ${DOCKER_HUB}/infra/noroutine-ca:${INFRA_VERSION} as rootca

FROM ${DOCKER_HUB}/bitnami/bitnami-shell:${BITNAMI_SHELL_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.me>"

# full bundle of CA certs set from Mozilla + Noroutine CA certs
USER 0
COPY --from=rootca /noroutine /usr/local/share/ca-certificates/noroutine
RUN install_packages ca-certificates
RUN update-ca-certificates
USER 1001
