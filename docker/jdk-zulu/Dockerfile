ARG DOCKER_HUB
ARG JDK_ZULU_VERSION
ARG INFRA_VERSION

FROM ${DOCKER_HUB}/infra/noroutine-ca:${INFRA_VERSION} as rootca

FROM ${DOCKER_HUB}/azul/zulu-openjdk:${JDK_ZULU_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"

RUN apt-get update && apt-get install -y \
    curl ca-certificates \
  && rm -rf /var/lib/apt/lists/*

COPY --from=rootca /noroutine /usr/local/share/ca-certificates/noroutine
RUN update-ca-certificates