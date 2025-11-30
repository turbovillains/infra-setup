ARG IMAGE_REGISTRY=cr.noroutine.me
ARG NEXTCLOUD_VERSION=dev

FROM ${IMAGE_REGISTRY}/library/nextcloud:${NEXTCLOUD_VERSION}

ADD ACCC4CF8.asc /etc/apt/keyrings/pgdg-archive-keyring.asc

RUN echo 'deb [signed-by=/etc/apt/keyrings/pgdg-archive-keyring.asc] http://apt.postgresql.org/pub/repos/apt trixie-pgdg main' > /etc/apt/sources.list.d/pgdg.list

RUN apt-get -yyq update && \
    apt-get -yyq install --no-install-recommends smbclient sudo && \
    apt-get -yyq install --target-release trixie-pgdg --no-install-recommends libpq5 postgresql-client-17 && \
    rm -rf /var/lib/apt/lists/*
