ARG IMAGE_REGISTRY=cr.nrtn.dev
ARG INFRA_NAMESPACE=infra-dev
ARG INFRA_VERSION=dev

FROM ${IMAGE_REGISTRY}/${INFRA_NAMESPACE}/noroutine-ca:${INFRA_VERSION} AS rootca

FROM ${IMAGE_REGISTRY}/${INFRA_NAMESPACE}/debian:${INFRA_VERSION}

RUN apt-get update && apt-get install -y \
    gnupg2 curl ca-certificates \
  && rm -rf /var/lib/apt/lists/*

RUN (                                    \
echo "Package: pdns-*"                  ;\
echo "Pin: origin repo.powerdns.com"    ;\
echo "Pin-Priority: 600"                ;\
) > /etc/apt/preferences.d/pdns

RUN (                                                                       \
echo "deb [signed-by=/etc/apt/keyrings/rec-versioned-pub.asc] http://repo.powerdns.com/debian trixie-rec-53 main" \
) > /etc/apt/sources.list.d/pdns.list

# master
COPY CBC8B383-pub.asc /etc/apt/keyrings/rec-master-pub.asc
# versioned
COPY FD380FBB-pub.asc /etc/apt/keyrings/rec-versioned-pub.asc

RUN apt-get update -qyy && \
    apt-get install -qyy pdns-recursor && \
    rm -rf /var/lib/apt/lists/*

COPY --from=rootca /noroutine /usr/local/share/ca-certificates/noroutine
RUN update-ca-certificates

EXPOSE 53/tcp 53/udp

CMD ["/usr/sbin/pdns_recursor"]
