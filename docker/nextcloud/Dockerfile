ARG DOCKER_HUB
ARG IMAGE_BASE
ARG IMAGE_VERSION
ARG INFRA_VERSION
ARG INFRA_NAMESPACE

FROM ${DOCKER_HUB}/${INFRA_NAMESPACE}/noroutine-ca:${INFRA_VERSION} AS rootca

FROM ${DOCKER_HUB}/${IMAGE_BASE}:${IMAGE_VERSION}

ADD ACCC4CF8.asc /etc/apt/keyrings/pgdg-archive-keyring.asc

RUN echo 'deb [signed-by=/etc/apt/keyrings/pgdg-archive-keyring.asc] http://apt.postgresql.org/pub/repos/apt trixie-pgdg main' > /etc/apt/sources.list.d/pgdg.list

RUN apt-get -yyq update && \
    apt-get -yyq install --no-install-recommends smbclient sudo && \
    apt-get -yyq install --target-release trixie-pgdg --no-install-recommends libpq5 postgresql-client-17 && \
    rm -rf /var/lib/apt/lists/*

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"

COPY --from=rootca /noroutine/ /usr/local/share/ca-certificates/noroutine
RUN update-ca-certificates
