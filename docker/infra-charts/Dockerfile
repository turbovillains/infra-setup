ARG DOCKER_HUB
ARG INFRA_VERSION
ARG INFRA_NAMESPACE

FROM ${DOCKER_HUB}/${INFRA_NAMESPACE}/caddy:${INFRA_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"

COPY ./charts /charts

EXPOSE 2019

ENTRYPOINT [ "caddy", "file-server", "--browse", "--access-log", "--root", "/charts", "--listen", "0.0.0.0:2019" ]
