ARG DOCKER_HUB
ARG INFRA_VERSION
FROM ${DOCKER_HUB}/infra/debian:${INFRA_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.me>"

ARG DOCKER_HUB
ARG BUILDPACKS_VERSION
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

ADD setup.sh /setup.sh
ADD setup.d /setup.d
ADD dotprofile/.bashrc /root/.bashrc

RUN --mount=type=secret,id=ssh_private_key --mount=type=secret,id=infra_readonly_token /setup.sh

ADD supervisor /etc/supervisor

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]