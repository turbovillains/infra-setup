#!/usr/bin/env bash -eux

export HTTP_PROXY=${HTTP_PROXY:-}
export HTTPS_PROXY=${HTTPS_PROXY:-}
export NO_PROXY=${NO_PROXY:-}

if [[ ! -z "${HTTP_PROXY}" ]]; then
    echo "Acquire::http::Proxy \"${HTTP_PROXY}\";" >> /etc/apt/apt.conf.d/00aptitude
fi

if [[ ! -z "${HTTPS_PROXY}" ]]; then
    echo "Acquire::https::Proxy \"${HTTPS_PROXY}\";" >> /etc/apt/apt.conf.d/00aptitude
fi

apt-get update -yyq
apt-get -y install unzip python3 python3-pip virtualenv openssh-client \
	apt-transport-https ca-certificates curl software-properties-common \
	gettext-base