ARG DOCKER_HUB
ARG INFRA_VERSION
ARG INFRA_NAMESPACE

FROM ${DOCKER_HUB}/${INFRA_NAMESPACE}/noroutine-ca:${INFRA_VERSION} as rootca

FROM ${DOCKER_HUB}/${INFRA_NAMESPACE}/debian:${INFRA_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"

RUN apt-get update && apt-get install -y \
    gnupg2 curl ca-certificates \
  && rm -rf /var/lib/apt/lists/*

RUN (                                    \
echo "Package: pdns-*"                  ;\
echo "Pin: origin repo.powerdns.com"    ;\
echo "Pin-Priority: 600"                ;\
) > /etc/apt/preferences.d/pdns

RUN (                                                                       \
echo "deb http://repo.powerdns.com/debian bookworm-auth-49 main" \
) > /etc/apt/sources.list.d/pdns.list

COPY CBC8B383-pub.asc /tmp/pdns-gpg-key-pub.asc
RUN apt-key add /tmp/pdns-gpg-key-pub.asc && rm /tmp/pdns-gpg-key-pub.asc

COPY FD380FBB-pub.asc /tmp/pdns-gpg-key-pub.asc
RUN apt-key add /tmp/pdns-gpg-key-pub.asc && rm /tmp/pdns-gpg-key-pub.asc

RUN apt-get update -qyy && \
    apt-get install -qyy pdns-server pdns-backend-sqlite3 pdns-backend-pgsql pdns-backend-lua2 pdns-backend-pipe python3 && \
    rm -rf /var/lib/apt/lists/*

COPY --from=rootca /noroutine /usr/local/share/ca-certificates/noroutine
RUN update-ca-certificates

# nip.io
COPY nipio/backend.py /opt/nip.io/
COPY nipio/backend.conf /opt/nip.io/

EXPOSE 53/tcp 53/udp

CMD ["/usr/sbin/pdns_server"]
