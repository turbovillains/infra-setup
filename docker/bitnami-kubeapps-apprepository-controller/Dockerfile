ARG DOCKER_HUB
ARG INFRA_VERSION
ARG BITNAMI_KUBEAPPS_APPREPOSITORY_CONTROLLER_VERSION

FROM ${DOCKER_HUB}/infra/noroutine-ca:${INFRA_VERSION} as rootca

FROM ${DOCKER_HUB}/bitnami/kubeapps-apprepository-controller:${BITNAMI_KUBEAPPS_APPREPOSITORY_CONTROLLER_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"

# full bundle of CA certs set from Mozilla + Noroutine CA certs
USER 0
COPY --from=rootca /ca-certificates.crt /etc/ssl/certs
USER 1001
