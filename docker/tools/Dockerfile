ARG DOCKER_HUB=docker.io
ARG DEBIAN_VERSION
FROM ${DOCKER_HUB}/library/debian:${DEBIAN_VERSION} AS download

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"

USER 0

ADD setup.sh /setup.sh
RUN /setup.sh

FROM scratch

COPY --from=download /usr/local/bin /usr/local/bin
