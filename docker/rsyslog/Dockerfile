ARG DOCKER_HUB
ARG INFRA_VERSION

FROM ${DOCKER_HUB}/infra/debian:${INFRA_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"

RUN apt-get update && \
    apt-get install rsyslog rsyslog-elasticsearch --no-install-recommends -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY rsyslog.conf /etc/

VOLUME /etc/rsyslog.d

EXPOSE 514
ENTRYPOINT ["rsyslogd", "-n", "-f", "/etc/rsyslog.conf"]
