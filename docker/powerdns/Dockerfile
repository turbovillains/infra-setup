ARG DOCKER_HUB
ARG INFRA_VERSION

FROM ${DOCKER_HUB}/infra/noroutine-ca:${INFRA_VERSION} as rootca

FROM ${DOCKER_HUB}/infra/debian:${INFRA_VERSION}

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
echo "deb [arch=amd64] http://repo.powerdns.com/debian bullseye-auth-47 main" \
) > /etc/apt/sources.list.d/pdns.list

COPY FD380FBB-pub.asc /tmp/FD380FBB-pub.asc
RUN apt-key add /tmp/FD380FBB-pub.asc && rm /tmp/FD380FBB-pub.asc

RUN apt-get update -qyy && \
    apt-get install -qyy pdns-server pdns-backend-sqlite3 pdns-backend-pgsql pdns-backend-lua2 && \
    rm -rf /var/lib/apt/lists/*

COPY --from=rootca /noroutine /usr/local/share/ca-certificates/noroutine
RUN update-ca-certificates

EXPOSE 53/tcp 53/udp

CMD ["/usr/sbin/pdns_server"]