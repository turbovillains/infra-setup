ARG DOCKER_HUB
ARG NEXTCLOUD_VERSION

FROM ${DOCKER_HUB}/nextcloud:${NEXTCLOUD_VERSION}

RUN set -ex; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        php-smbclient \
    ; \
    rm -rf /var/lib/apt/lists/*;

MAINTAINER Noroutine GmbH <info@noroutine.me>
