ARG DOCKER_HUB
ARG UNBOUND_BASE

FROM ${DOCKER_HUB}/${UNBOUND_BASE}

MAINTAINER Noroutine GmbH <info@noroutine.me>

RUN apt-get update && apt-get install -y \
    gnupg2 curl unbound \
  && rm -rf /var/lib/apt/lists/*

EXPOSE 53/tcp 53/udp

ENTRYPOINT ["/usr/sbin/unbound", "-d"]