ARG DOCKER_HUB=docker.io
ARG INFRA_VERSION
ARG INFRA_NAMESPACE
FROM ${DOCKER_HUB}/${INFRA_NAMESPACE}/debian:${INFRA_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"

ARG DOCKER_HUB=docker.io
ARG GIT_SERVER_HOST

ARG HOST_DOCKER_GID

ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG NO_PROXY

ENV DOCKER_HUB=${DOCKER_HUB} \
  DOCKER_CLI_EXPERIMENTAL=enabled \
  DOCKER_BUILDKIT=1 \
  BUILDER_USER=builder

ADD setup /setup
RUN --mount=type=secret,id=ssh_private_key --mount=type=secret,id=infra_readonly_token /setup/setup.sh

# Bash wrapper to drop permissions
# RUN mv /bin/bash /bin/bash.real
# COPY --chown=0:0 gitlab-shell /bin/bash
# RUN chmod +x /bin/bash

USER ${BUILDER_USER}
WORKDIR /home/builer