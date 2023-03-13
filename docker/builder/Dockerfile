ARG DOCKER_HUB=docker.io
ARG INFRA_VERSION
FROM ${DOCKER_HUB}/infra/debian:${INFRA_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"

ARG DOCKER_HUB=docker.io
ARG BUILDPACKS_VERSION
ARG ACTIONS_RUNNER_VERSION=2.303.0
ARG GIT_SERVER_HOST

ARG HOST_DOCKER_GID

ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG NO_PROXY

ENV DOCKER_HUB=${DOCKER_HUB} \
  DOCKER_CLI_EXPERIMENTAL=enabled \
  DOCKER_BUILDKIT=1 \
  BUILDPACKS_VERSION=${BUILDPACKS_VERSION} \
  BUILDER_USER=builder \
  ACTIONS_RUNNER_VERSION=${ACTIONS_RUNNER_VERSION} \
  ARCH=x64 \
  RUNNER_ASSETS_DIR=/runnertmp \
  RUNNER_TOOL_CACHE=/opt/hostedtoolcache \
  RUNNER_USER=builder \
  ImageOS=debian11

ADD setup /setup
RUN --mount=type=secret,id=ssh_private_key --mount=type=secret,id=infra_readonly_token /setup/setup.sh

# For GH Action Runner
COPY actions-runner-entrypoint.sh logger.bash /usr/local/bin/

# Bash wrapper to drop permissions
# RUN mv /bin/bash /bin/bash.real
# COPY --chown=0:0 gitlab-shell /bin/bash
# RUN chmod +x /bin/bash

USER ${RUNNER_USER}
WORKDIR /home/builer

# For GH Action Runner
CMD ["/usr/local/bin/actions-runner-entrypoint.sh"]
