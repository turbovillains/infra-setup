ARG DOCKER_HUB
ARG INFRA_VERSION
FROM ${DOCKER_HUB}/infra/debian:${INFRA_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.me>"

ARG DOCKER_HUB
ARG BUILDPACKS_VERSION
ARG ACTIONS_RUNNER_VERSION=2.278.0
ARG GIT_SERVER_HOST

ARG HOST_DOCKER_GID

ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG NO_PROXY

ENV GIT_SERVER_HOST=${GIT_SERVER_HOST}

ENV DOCKER_HUB=${DOCKER_HUB}
ENV BUILDPACKS_VERSION=${BUILDPACKS_VERSION}
ENV BUILDER_USER=builder

# ENV ALL_PROXY=${HTTP_PROXY} \
#   http_proxy=${HTTP_PROXY} \
#   HTTP_PROXY=${HTTP_PROXY} \
#   https_proxy=${HTTPS_PROXY}} \
#   HTTPS_PROXY=${HTTPS_PROXY}} \
#   NO_PROXY=${NO_PROXY}} \
#   no_proxy=${NO_PROXY}}

# For GH Action Runner
ENV ACTIONS_RUNNER_VERSION=${ACTIONS_RUNNER_VERSION}
ENV ARCH=x64
ENV RUNNER_ASSETS_DIR=/runnertmp
ENV RUNNER_TOOL_CACHE=/opt/hostedtoolcache
ENV RUNNER_USER=builder
ENV ImageOS=debian11

ADD setup.sh /setup.sh
ADD setup.d /setup.d
ADD dotprofile/.bashrc /root/.bashrc

RUN --mount=type=secret,id=ssh_private_key --mount=type=secret,id=infra_readonly_token /setup.sh

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
