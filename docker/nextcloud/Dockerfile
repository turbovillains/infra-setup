ARG DOCKER_HUB
ARG NEXTCLOUD_VERSION

FROM ${DOCKER_HUB}/nextcloud:${NEXTCLOUD_VERSION}

RUN apt-get -yyq update; \
    apt-get -yyq install --no-install-recommends smbclient; \
    rm -rf /var/lib/apt/lists/*;

MAINTAINER Noroutine GmbH <info@noroutine.me>
