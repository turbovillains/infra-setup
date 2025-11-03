ARG IMAGE_REGISTRY=cr.nrtn.dev
ARG INFRA_NAMESPACE=infra-dev
ARG INFRA_VERSION=dev
ARG IMAGE_BASE=debian
ARG IMAGE_VERSION=dev

FROM ${IMAGE_REGISTRY}/${INFRA_NAMESPACE}/noroutine-ca:${INFRA_VERSION} AS rootca

FROM ${IMAGE_REGISTRY}/${IMAGE_BASE}:${IMAGE_VERSION}

ADD ACCC4CF8.asc /etc/apt/keyrings/pgdg-archive-keyring.asc

RUN echo 'deb [signed-by=/etc/apt/keyrings/pgdg-archive-keyring.asc] http://apt.postgresql.org/pub/repos/apt trixie-pgdg main' > /etc/apt/sources.list.d/pgdg.list

RUN apt-get -yyq update && \
    apt-get -yyq install --no-install-recommends smbclient sudo && \
    apt-get -yyq install --target-release trixie-pgdg --no-install-recommends libpq5 postgresql-client-17 && \
    rm -rf /var/lib/apt/lists/*

COPY --from=rootca /noroutine/ /usr/local/share/ca-certificates/noroutine
RUN update-ca-certificates
