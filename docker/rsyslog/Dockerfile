ARG DOCKER_HUB
ARG DEBIAN_VERSION

FROM ${DOCKER_HUB}/debian:${DEBIAN_VERSION}

MAINTAINER Noroutine GmbH <info@noroutine.me>

RUN apt-get update && \
    apt-get install rsyslog rsyslog-elasticsearch --no-install-recommends -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY rsyslog.conf /etc/

VOLUME /etc/rsyslog.d

EXPOSE 514
ENTRYPOINT ["rsyslogd", "-n", "-f", "/etc/rsyslog.conf"]