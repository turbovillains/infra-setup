ARG DOCKER_HUB
ARG NEXTCLOUD_VERSION
ARG INFRA_VERSION

FROM ${DOCKER_HUB}/infra/noroutine-ca:${INFRA_VERSION} as rootca

FROM ${DOCKER_HUB}/nextcloud:${NEXTCLOUD_VERSION}

RUN apt-get -yyq update; \
    apt-get -yyq install --no-install-recommends smbclient; \
    rm -rf /var/lib/apt/lists/*;

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.me>"

COPY --from=rootca /noroutine/ /usr/local/share/ca-certificates/noroutine
RUN update-ca-certificates