ARG DOCKER_HUB
ARG POWERDNS_BASE

FROM ${DOCKER_HUB}/${POWERDNS_BASE}

MAINTAINER Noroutine UG <info@noroutine.me>

RUN apt-get update && apt-get install -y \
    gnupg2 curl \
  && rm -rf /var/lib/apt/lists/*

RUN (                                    \
echo "Package: pdns-*"                  ;\
echo "Pin: origin repo.powerdns.com"    ;\
echo "Pin-Priority: 600"                ;\
) > /etc/apt/preferences.d/pdns

RUN (                                                                       \
echo "deb [arch=amd64] http://repo.powerdns.com/debian buster-auth-43 main" \
) > /etc/apt/sources.list.d/pdns.list

RUN curl -s https://repo.powerdns.com/FD380FBB-pub.asc | apt-key add -

RUN apt-get update && apt-get install -y \
    pdns-server \
 && rm -rf /var/lib/apt/lists/*

EXPOSE 53/tcp 53/udp

CMD ["/usr/sbin/pdns_server"]