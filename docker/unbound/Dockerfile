ARG DOCKER_HUB
ARG UNBOUND_BASE

FROM ${DOCKER_HUB}/${UNBOUND_BASE}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.me>"

RUN apt-get update && apt-get install -y \
    gnupg2 curl unbound \
  && rm -rf /var/lib/apt/lists/*

ADD https://www.internic.net/domain/named.root /etc/unbound/root.hints

EXPOSE 53/tcp 53/udp

ENTRYPOINT ["/usr/sbin/unbound", "-d"]