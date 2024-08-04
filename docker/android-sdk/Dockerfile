ARG DOCKER_HUB=cr.nrtn.dev
ARG JDK_ZULU_VERSION=22.0.2-22.32
ARG INFRA_VERSION=v0.0.347
ARG INFRA_NAMESPACE=infra

FROM ${DOCKER_HUB}/${INFRA_NAMESPACE}/noroutine-ca:${INFRA_VERSION} as rootca

FROM ${DOCKER_HUB}/azul/zulu-openjdk:${JDK_ZULU_VERSION}

ARG GRADLE_URL_BASE=https://services.gradle.org/distributions
ARG GRADLE_VERSION=8.9
ARG ANDROID_SDK_TOOLS_URL_BASE=https://dl.google.com/android/repository
ARG ANDROID_SDK_TOOLS_VERSION=11076708
ARG ANDROID_SDK_TOOLS_CHECKSUM=2d2d50857e4eb553af5a6dc3ad507a17adf43d115264b1afc116f95c92e5e258

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"

RUN apt-get update && apt-get install -y \
    curl ca-certificates \
  && rm -rf /var/lib/apt/lists/*

COPY --from=rootca /noroutine /usr/local/share/ca-certificates/noroutine
RUN update-ca-certificates

# Command line tools only
# https://developer.android.com/studio/index.html
ENV ANDROID_SDK_TOOLS_VERSION=${ANDROID_SDK_TOOLS_VERSION}
ENV ANDROID_SDK_TOOLS_CHECKSUM=${ANDROID_SDK_TOOLS_CHECKSUM}

ENV GRADLE_VERSION=${GRADLE_VERSION}

ENV ANDROID_HOME="/opt/android-sdk-linux"
ENV ANDROID_SDK_ROOT=${ANDROID_HOME}
ENV PATH=$PATH:${ANDROID_HOME}/cmdline-tools:${ANDROID_HOME}/cmdline-tools/bin:${ANDROID_HOME}/platform-tools

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

# Download and unzip Android SDK Tools
RUN curl -s ${ANDROID_SDK_TOOLS_URL_BASE}/commandlinetools-linux-${ANDROID_SDK_TOOLS_VERSION}_latest.zip > /tools.zip \
  && echo "${ANDROID_SDK_TOOLS_CHECKSUM} ./tools.zip" | sha256sum -c \
  && unzip -qq /tools.zip -d ${ANDROID_HOME} \
  && rm -v /tools.zip

# Accept licenses
RUN mkdir -p ${ANDROID_HOME}/licenses/ \
  && echo "8933bad161af4178b1185d1a37fbf41ea5269c55\nd56f5187479451eabf01fb78af6dfcb131a6481e\n24333f8a63b6825ea9c5514f83c2829b004d1fee" > ${ANDROID_HOME}/licenses/android-sdk-license \
  && echo "84831b9409646a918e30573bab4c9c91346d8abd\n504667f4c0de7af1a06de9f4b1727b84351f2910" > ${ANDROID_HOME}/licenses/android-sdk-preview-license --licenses \
  && yes | ${ANDROID_HOME}/cmdline-tools/bin/sdkmanager --licenses --sdk_root=${ANDROID_SDK_ROOT}

# Add folder for SDK files
RUN mkdir -p /home/android/.android \
  && mkdir -p /home/android/app \
  && touch /home/android/.android/repositories.cfg

ENV HOME=/home/android
WORKDIR ${HOME}/app

# Install Android packages
ADD packages.txt ${HOME}

# Update sdkmanager
RUN ${ANDROID_HOME}/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --update \
  && while read -r pkg; do PKGS="${PKGS}${pkg} "; done < ${HOME}/packages.txt \
  && ${ANDROID_HOME}/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_SDK_ROOT} $PKGS \
  && rm ${HOME}/packages.txt

# Download and install Gradle
RUN curl -L ${GRADLE_URL_BASE}/gradle-${GRADLE_VERSION}-bin.zip -o gradle-bin.zip && \
  unzip -d /opt gradle-bin.zip && \
  rm gradle-bin.zip

# Export some environment variables
ENV GRADLE_HOME=/opt/gradle-${GRADLE_VERSION}
ENV PATH=${PATH}:${GRADLE_HOME}/bin

RUN gradle --version
