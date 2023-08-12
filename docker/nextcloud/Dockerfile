ARG DOCKER_HUB
ARG NEXTCLOUD_VERSION
ARG INFRA_VERSION

FROM ${DOCKER_HUB}/infra/noroutine-ca:${INFRA_VERSION} as rootca

FROM ${DOCKER_HUB}/nextcloud:${NEXTCLOUD_VERSION}

ADD ACCC4CF8.asc /etc/apt/keyrings/pgdg-archive-keyring.asc

RUN echo 'deb [signed-by=/etc/apt/keyrings/pgdg-archive-keyring.asc] http://apt.postgresql.org/pub/repos/apt bookworm-pgdg main' > /etc/apt/sources.list.d/pgdg.list

RUN apt-get -yyq update && \
    apt-get -yyq install --no-install-recommends smbclient sudo && \
    apt-get -yyq install --target-release bookworm-pgdg --no-install-recommends libpq5 postgresql-client-15 && \
    rm -rf /var/lib/apt/lists/*

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"

COPY --from=rootca /noroutine/ /usr/local/share/ca-certificates/noroutine
RUN update-ca-certificates
