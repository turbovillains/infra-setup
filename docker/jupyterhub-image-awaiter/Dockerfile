ARG DOCKER_HUB
ARG INFRA_VERSION
ARG INFRA_NAMESPACE
ARG JUPYTERHUB_IMAGE_AWAITER_VERSION

FROM ${DOCKER_HUB}/${INFRA_NAMESPACE}/noroutine-ca:${INFRA_VERSION} as rootca

FROM ${DOCKER_HUB}/jupyterhub/k8s-image-awaiter:${JUPYTERHUB_IMAGE_AWAITER_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"
