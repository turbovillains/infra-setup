ARG DOCKER_HUB
ARG INFRA_VERSION
ARG JUPYTERHUB_SECRET_SYNC_VERSION

FROM ${DOCKER_HUB}/infra/noroutine-ca:${INFRA_VERSION} as rootca

FROM ${DOCKER_HUB}/jupyterhub/k8s-secret-sync:${JUPYTERHUB_SECRET_SYNC_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"
