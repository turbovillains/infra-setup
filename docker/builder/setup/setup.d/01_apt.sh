#!/usr/bin/env bash -eux

# if [[ ! -z "${HTTP_PROXY}" ]]; then
#     echo "Acquire::http::Proxy \"${HTTP_PROXY}\";" >> /etc/apt/apt.conf.d/00proxy
#     echo "Acquire::https::Proxy \"${HTTPS_PROXY}\";" >> /etc/apt/apt.conf.d/00proxy
# fi

export DEBIAN_FRONTEND=noninteractive

cat << SOURCES > /etc/apt/sources.list
deb http://deb.debian.org/debian bullseye main
deb http://deb.debian.org/debian bullseye-updates main
deb http://security.debian.org/debian-security bullseye-security main
SOURCES

apt-get update -yyq
apt-get -yyq install zip zstd unzip upx \
	python3 python3-pip virtualenv \
	socat netcat telnet curl wget ftp git \
  protobuf-compiler \
  rsync \
  build-essential procps file libunwind8 \
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
  qemu binfmt-support qemu-user-static

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

# cat << SOURCES >> /etc/apt/sources.list.d/noroutine.list
# deb https://nexus.nrtn.dev/repository/apps-apt/ noroutine main
# SOURCES

# cat <<NOROUTINEREPO | apt-key add -
# -----BEGIN PGP PUBLIC KEY BLOCK-----

# mQINBGH1S7cBEACy8v+8Ym9uaDCE1aDSVyqSyjyGFAYbGu7pT2YKHo906UDsiKNU
# znkL8DrzSpm5rZpeQxAWyuGEShTJ/G4dQ/s6syx/b7FQ81sfScIQphcIv800ZFEJ
# gkKAgggND16KIiZDt2lpWSHLDD4dweORLM++DYLrEM9dvhzUzi9cojMnELe5q8p4
# PhWgoxnYbSjcAsrZUW7KsWdsRbAC7SmjlNJl29adRUI83yghk1gQBAtJyczmqp77
# Km4mHdJq+tDRE7wicjHJirkEQC8dnX4IrtLf7C7y99Wu6vJJHTn9m00vjCQm/dE7
# W0qoRGCRzNbGBpA19ALc5T59QqtWK4tANDuPQtvpJtuAGWON3e9B7qOTjA1e/4Wq
# Fr2Ft7fGfc+XJAiOvafXGiIgWeExFMMZ4pJ9+DCkha8zmE75pg6FP0taYYitPCIN
# ItgR4PNmMjneZEMu8Q+uFvfbZ0a7mogzryHCI0UmC7S9x+9GQEA4x72giYmOB3nf
# V+yj36KptO7A3dX4avfSqizZYuaLnhXMBaFjvtalhSfAO7tjIqJm1YKTd4azJ6SX
# ego3WtrFX79RuBvGS0wr1EcXJ3/hjJlvCPLCeP4SyMaNvUFl9mCPXgMzSc1YZuKp
# G+5mLkBvewQ1T8c+B1uJcWW57LE5uc9fMj2fr1W1yN6KaYulFDdr6JbH8wARAQAB
# tDFOb3JvdXRpbmUgQVBUIFJlcG9zaXRvcmllcyA8c3VwcG9ydEBub3JvdXRpbmUu
# bWU+iQJUBBMBCgA+FiEEVvRa5MSdMlJauXADhiyfpBXVB1AFAmH1S7cCGwMFCQHh
# M4AFCwkIBwIGFQoJCAsCBBYCAwECHgECF4AACgkQhiyfpBXVB1DMqBAAk4N0VRLa
# vahLQQHu4oQ0WISZf8yVT92gLlksgoRrXeFBdoWFusklddLFFOY6NfBuwLS+X+ZD
# 5SaHNDePpPMQeVY6/bx9KR5HKQWsiB6qdtropEjJ7u9YplUaeQmRFnW4ANlKOmCp
# t1VXbg9DDtn8mPKbSftKjyrv3ddUyrbZG7szylY3IgqmS4ywDfP6f/1/el0XeDMB
# f5iNGCe7yr32/GUlgalF/zE5j51gHsRTg9QvHNEibs2qDC+nVho9BQevZwrXkJin
# 7K1mZz7s1zgRPdMLZLBibav5rqX48qpATGzpp6ovHSqHNH6f9JTRS5WMuMELnejR
# GOjaSQEBiwrbf7ULJYxBkLNRVBZl7HVIB4tGbuo/frJ0s9dXIgpayhnDNmjINdC8
# smaMiljd1qCivn10KOx36HI52DkR0x0HVBuc+BiZfUZdRNAh5iDD1/9z0HJnTd/u
# 8c0u+ViySbprpTAamgKmZTpEvcP7QtlmBrCbKzYlQfGjDpMFYVLa/JG5Y/uPfgDb
# uKlXs/xFqIBqY8Qj1UIZtmKIyhxvFvJZshH4EqJUPN6zJnc4fwbNsk9GirNxqmr3
# +gYF7JFuhz6mk7PqmKZ+tqeINJvSiZ9e+1CvCrCKbiOrWWBa7Y/4SKOPAewbMs79
# SEJc2q8s8drOLd6T5cvVNexnulHjc040R7K5Ag0EYfVLtwEQAMbLd9iVm2+7YkQm
# 7os6aujuzddx4nzvVfuocoJcgMZaqe7TuGtyTi057Bkpc8c3xaBZ2w0q5Rx3qLtq
# Ma3u/L9mVlPr7hL2bHkogh8ZStkji4OywNNa5SRKocMM1r6hPe5SW3zjc9/qljYK
# CzmejJzaP5GYQRdt662I9DofHvAq6UyjfyAsGLfRewvNwkP5tpaWrS5Q18judhGu
# ah6BRShKGCo9sSlCdDJbGc28QRQczbqBTrXE9/3My8jIXgIFNHbIA818OMccqmDb
# jLCaUsqQpU1smkspTZfzK+rQi9m+7uwhf0sia64SwuuXxzW9ZrY6jgCCkcojjvC9
# //5PcaTxVVBf3W7imTZ7Fsmk4kUEFIMl948B2/kl+M2yzS9ZbQgQd3Ed+LtDD9l+
# gAojrQUMuJjaubqQqhwyZndYrdj3PKOoD5xBUNUpBszv9SfxLigEfVrDunwcnHaz
# hS8EQkSAx4rDBOoovV9oaZ3+E7scjWsaQKplUQUVDaqVE8JP38526bbQMnGNEX28
# Z4Bt6EjdCnq5IbShaHV2YKqhkZvQdkEJOiWdS0TKoFYYBq7LCIfYKZIuNMkqKPp9
# KFzhxOPykkK4Tsg+pP+J08am3eg3WKeTwBoqzFy2PmLAXHP1G3nvpM9e37v5WSOp
# DGvXFKsi/0sCTc5JTEWZ536TYPV3ABEBAAGJAjwEGAEKACYWIQRW9FrkxJ0yUlq5
# cAOGLJ+kFdUHUAUCYfVLtwIbDAUJAeEzgAAKCRCGLJ+kFdUHUMyTD/0SS38S696a
# h2X28xH/00DQpYSbCNOuYp5c45Pv/KsOTTmB9Y9QH2B8MeH2JfBZqkcc3TOpalrl
# EoZb0AhsDGbvh0ZjTQpmRuiO24lb/AqmfjoRBozDyYTfVeDXJ4uqzo1Vg2k90nnR
# XbUEpXtMDjU/ZrEmWr8FsxS5MK8+xzHIcrvLpHJFM8+sP/9seGpWk49+ciuiQp5O
# 153MmYcV6MGkcp9MdZJ/yblkj6+CKNg66F4xs8XJ/4PiuP80QT7fUeaTDBnbZ5Jb
# 0aHtTGnnAWT933uHiiP8Y2GOTksN4RopEU/cy/QyAXGwQzArAiGl7WwJK6SCOydB
# hBwGSoSziYaaOhlQyBm8HifQyUQLKdw7AUyTfjyRzIxUXAZoue1myq3CCj6nPhsv
# 3Ug/l/+nieo+ipUhxHz236gjt7YjyDw5EOGT6nyGahGUmj8AVxLHIWY+Y2+7hURB
# QqZ1V69tQXlEaWyKHqmEJbzCouG97apj8i2E9uwD1rn5UcxYEDEigzF1G2jJCJEx
# SJ+wy7ER9BpNymStJR5cqVIsYjFvW/BgB9I4CdNOe+bfYHw/3e1JbKT/PP+0vZko
# IROap33AeXBvLuMZexAK8h3PrUWX27b0rfg17bOPmnO63e+3WI4TCUpcJtNq8dxn
# 4dhYp/dJipzPfRcCIPFdj7AJ0dI5Cjp3SQ==
# =z8jO
# -----END PGP PUBLIC KEY BLOCK-----
# NOROUTINEREPO

# Docker
cat <<EOK | apt-key add -
-----BEGIN PGP PUBLIC KEY BLOCK-----

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
YT90qFF93M3v01BbxP+EIY2/9tiIPbrd
=0YYh
-----END PGP PUBLIC KEY BLOCK-----
EOK

add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/debian \
  $(lsb_release -cs) \
  stable"

apt-get update -yyq
apt-get install -yyq docker-ce docker-ce-cli containerd.io

# Should match runner GID
groupmod --gid ${HOST_DOCKER_GID} docker


apt-get install -yyq sudo
