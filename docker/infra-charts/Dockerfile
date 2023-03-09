ARG DOCKER_HUB
ARG INFRA_VERSION

FROM ${DOCKER_HUB}/infra/caddy:${INFRA_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"

COPY ./charts /charts

EXPOSE 2019

ENTRYPOINT [ "caddy", "file-server", "--browse", "--access-log", "--root", "/charts", "--listen", "0.0.0.0:2019" ]
