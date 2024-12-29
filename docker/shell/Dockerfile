ARG DOCKER_HUB
ARG INFRA_VERSION
ARG INFRA_NAMESPACE

FROM ${DOCKER_HUB}/${INFRA_NAMESPACE}/tools:${INFRA_VERSION} AS tools

FROM ${DOCKER_HUB}/${INFRA_NAMESPACE}/debian:${INFRA_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"

ARG HOST_DOCKER_GID

COPY --from=tools /usr/local/bin /usr/local/bin

ENV BUILDER_USER=builder

ADD setup /setup

RUN --mount=type=secret,id=ssh_private_key --mount=type=secret,id=infra_readonly_token /setup/setup.sh

ADD supervisor /etc/supervisor

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
