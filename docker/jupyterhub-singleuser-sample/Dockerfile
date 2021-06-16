ARG DOCKER_HUB
ARG INFRA_VERSION
ARG JUPYTERHUB_SINGLEUSER_SAMPLE_VERSION

FROM ${DOCKER_HUB}/infra/noroutine-ca:${INFRA_VERSION} as rootca

FROM ${DOCKER_HUB}/jupyterhub/k8s-singleuser-sample:${JUPYTERHUB_SINGLEUSER_SAMPLE_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.me>"
