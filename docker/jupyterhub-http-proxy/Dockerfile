ARG DOCKER_HUB
ARG INFRA_VERSION
ARG JUPYTERHUB_HTTP_PROXY_VERSION

FROM ${DOCKER_HUB}/infra/noroutine-ca:${INFRA_VERSION} as rootca

FROM ${DOCKER_HUB}/jupyterhub/configurable-http-proxy:${JUPYTERHUB_HTTP_PROXY_VERSION}

MAINTAINER Noroutine GmbH <info@noroutine.me>
