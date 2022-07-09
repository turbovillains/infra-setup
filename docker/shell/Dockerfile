ARG DOCKER_HUB
ARG INFRA_VERSION
FROM ${DOCKER_HUB}/infra/debian:${INFRA_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"

ARG HOST_DOCKER_GID

ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG NO_PROXY

ENV BUILDER_USER=builder

ADD setup /setup

RUN --mount=type=secret,id=ssh_private_key --mount=type=secret,id=infra_readonly_token /setup/setup.sh

ADD supervisor /etc/supervisor

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]