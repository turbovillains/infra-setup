ARG DOCKER_HUB
ARG BUILDER_BASE
FROM ${DOCKER_HUB}/${BUILDER_BASE}

MAINTAINER Noroutine GmbH <info@noroutine.me>

ARG DOCKER_HUB
ARG BUILDPACKS_VERSION
ARG ACTIONS_RUNNER_VERSION=2.278.0
ARG GIT_SERVER_HOST
ARG SSH_PRIVATE_KEY
ARG HOST_DOCKER_GID

ENV GIT_SERVER_HOST=${GIT_SERVER_HOST}
ENV SSH_PRIVATE_KEY=${SSH_PRIVATE_KEY}
ENV DOCKER_HUB=${DOCKER_HUB}
ENV BUILDPACKS_VERSION=${BUILDPACKS_VERSION}
ENV BUILDER_USER=builder

# For GH Action Runner
ENV ARCH=x64
ENV RUNNER_ASSETS_DIR=/runnertmp
ENV RUNNER_USER=builder

ADD setup.sh /setup.sh
ADD setup.d /setup.d
ADD dotprofile/.bashrc /root/.bashrc

RUN /setup.sh

COPY actions-runner-entrypoint.sh /
COPY --chown=${RUNNER_USER}:docker patched ${RUNNER_ASSETS_DIR}/patched

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
