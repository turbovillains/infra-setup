ARG DOCKER_HUB
ARG DEBIAN_VERSION

FROM ${DOCKER_HUB}/debian:${DEBIAN_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.me>"

RUN apt-get update && apt-get install -yyq gnupg2 curl unbound && \
  rm -rf /var/lib/apt/lists/*

ADD https://www.internic.net/domain/named.root /etc/unbound/root.hints

EXPOSE 53/tcp 53/udp

ENTRYPOINT ["/usr/sbin/unbound", "-d"]