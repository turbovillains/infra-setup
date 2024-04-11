ARG DOCKER_HUB
ARG INFRA_VERSION
ARG INFRA_NAMESPACE

FROM ${DOCKER_HUB}/${INFRA_NAMESPACE}/mkdocs:${INFRA_VERSION} as build

ADD docs /docs

RUN mkdocs build

FROM ${DOCKER_HUB}/${INFRA_NAMESPACE}/caddy:${INFRA_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"

COPY --from=build /docs/site /data

ENTRYPOINT [ "caddy", "file-server", "--browse", "--access-log", "--root", "/data", "--listen", "0.0.0.0:2019" ]
