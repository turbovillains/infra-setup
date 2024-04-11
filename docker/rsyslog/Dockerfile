ARG DOCKER_HUB
ARG INFRA_VERSION
ARG INFRA_NAMESPACE

FROM ${DOCKER_HUB}/${INFRA_NAMESPACE}/debian:${INFRA_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"

RUN apt-get update && \
    apt-get install rsyslog rsyslog-elasticsearch --no-install-recommends -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY rsyslog.conf /etc/

VOLUME /etc/rsyslog.d

EXPOSE 514
ENTRYPOINT ["rsyslogd", "-n", "-f", "/etc/rsyslog.conf"]
