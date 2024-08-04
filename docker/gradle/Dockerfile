ARG DOCKER_HUB=cr.nrtn.dev
ARG JDK_ZULU_VERSION=22.0.2-22.32
ARG INFRA_VERSION=v0.0.347
ARG INFRA_NAMESPACE=infra

FROM ${DOCKER_HUB}/${INFRA_NAMESPACE}/noroutine-ca:${INFRA_VERSION} as rootca

FROM ${DOCKER_HUB}/azul/zulu-openjdk:${JDK_ZULU_VERSION}

ARG GRADLE_URL_BASE=https://services.gradle.org/distributions
ARG GRADLE_VERSION=8.9

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"

RUN apt-get update && apt-get install -y \
    curl ca-certificates \
  && rm -rf /var/lib/apt/lists/*

COPY --from=rootca /noroutine /usr/local/share/ca-certificates/noroutine
RUN update-ca-certificates

ENV GRADLE_VERSION=${GRADLE_VERSION}

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG en_US.UTF-8

RUN apt-get -qq update \
  && apt-get -qqy --no-install-recommends install \
  tar unzip lib32stdc++6 lib32z1 \
  apt-utils \
  build-essential \
  software-properties-common \
  libssl-dev \
  libffi-dev \
  python3-dev \
  cargo \
  pkg-config\
  libstdc++6 \
  libpulse0 \
  libglu1-mesa \
  openssh-server \
  zip \
  unzip \
  curl \
  lldb \
  git > /dev/null \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV HOME=/home/gradle
WORKDIR ${HOME}/app

# Download and install Gradle
RUN curl -L ${GRADLE_URL_BASE}/gradle-${GRADLE_VERSION}-bin.zip -o gradle-bin.zip && \
  unzip -d /opt gradle-bin.zip && \
  rm gradle-bin.zip

# Export some environment variables
ENV GRADLE_HOME=/opt/gradle-${GRADLE_VERSION}
ENV PATH=${PATH}:${GRADLE_HOME}/bin

RUN gradle --version
