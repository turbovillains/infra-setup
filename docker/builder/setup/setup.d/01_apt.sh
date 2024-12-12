#!/usr/bin/env bash -eux

export DEBIAN_FRONTEND=noninteractive

cat << SOURCES > /etc/apt/sources.list
deb https://fs.noroutine.me/attic/debian bookworm main
deb https://fs.noroutine.me/attic/debian bookworm-updates main
deb http://security.debian.org/debian-security bookworm-security main
SOURCES

apt-get update -yyq
apt-get -yyq install zip zstd unzip \
	python3 python3-pip virtualenv \
	arping socat netcat-openbsd telnet curl wget ftp git \
  openjdk-17-jdk \
  protobuf-compiler \
  rsync \
  make build-essential procps file libunwind8 \
  apt-transport-https apt-utils \
  ca-certificates \
  parallel shellcheck \
  gnupg2 \
  vim \
  freeipmi \
  postgresql-client openssh-client \
  iproute2 iputils-ping dnsutils \
  software-properties-common \
  supervisor \
  qemu-kvm binfmt-support qemu-user-static

# Locale
apt-get install -yyq locales
localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

export LANG=en_US.UTF8
export LC_ALL=en_US.UTF8

cat <<LOCALE >> /etc/environment
export LANG=en_US.UTF8
export LC_ALL=en_US.UTF8
LOCALE

# Noroutine
export CA_CERTS_DIR=/usr/local/share/ca-certificates/noroutine
mkdir -p ${CA_CERTS_DIR}

cat << NOROUTINE_ROOT_CA > ${CA_CERTS_DIR}/noroutine-root.crt
-----BEGIN CERTIFICATE-----
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
-----END CERTIFICATE-----
NOROUTINE_ROOT_CA

cat << NOROUTINE_TRUSTED_CA > ${CA_CERTS_DIR}/noroutine-trusted.crt
-----BEGIN CERTIFICATE-----
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
iSEzh0Nw32wEpWOXI/ZDEL7uUzjHSabA9WtC
-----END CERTIFICATE-----
NOROUTINE_TRUSTED_CA

update-ca-certificates


# Docker
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -yyq
apt-get install -yyq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Bookworm fix
apt-get remove -yqq --purge systemd-timesyncd
userdel systemd-timesync

# Should match runner GID
groupmod --gid ${HOST_DOCKER_GID} docker

apt-get install -yyq sudo
