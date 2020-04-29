#!/usr/bin/env bash -eux

export HTTP_PROXY=${HTTP_PROXY:-}
export NO_PROXY=${NO_PROXY:-}

if [[ ! -z "${HTTP_PROXY}" ]]; then
    echo "Acquire::http::Proxy \"${HTTP_PROXY}\";" >> /etc/apt/apt.conf.d/00aptitude
    echo "Acquire::https::Proxy \"${HTTPS_PROXY}\";" >> /etc/apt/apt.conf.d/00aptitude
fi

export DEBIAN_FRONTEND=noninteractive

apt-get update -yyq
apt-get -y install unzip \
	python3 python3-pip virtualenv \
	socat netcat curl \
    protobuf-compiler \
    rsync \
    make build-essential \
    apt-transport-https apt-utils \
    ca-certificates \
    curl \
    gnupg2 \
    software-properties-common

# Noroutine
export CA_CERTS_DIR=/usr/local/share/ca-certificates/noroutine
mkdir -p ${CA_CERTS_DIR}

cat << NOROUTINE_ROOT_CA > ${CA_CERTS_DIR}/noroutine-root.crt
-----BEGIN CERTIFICATE-----
MIIF+jCCA+KgAwIBAgIJANNTQ9Z+xkMjMA0GCSqGSIb3DQEBCwUAMIGJMQswCQYD
VQQGEwJERTEPMA0GA1UECAwGQmF5ZXJuMQ8wDQYDVQQHDAZNdW5pY2gxFzAVBgNV
BAoMDk5vcm91dGluZSBHbWJIMRowGAYDVQQDDBFOb3JvdXRpbmUgUm9vdCBDQTEj
MCEGCSqGSIb3DQEJARYUc3VwcG9ydEBub3JvdXRpbmUubWUwHhcNMTcxMjEzMTkx
ODIyWhcNMzcxMjA4MTkxODIyWjCBiTELMAkGA1UEBhMCREUxDzANBgNVBAgMBkJh
eWVybjEPMA0GA1UEBwwGTXVuaWNoMRcwFQYDVQQKDA5Ob3JvdXRpbmUgR21iSDEa
MBgGA1UEAwwRTm9yb3V0aW5lIFJvb3QgQ0ExIzAhBgkqhkiG9w0BCQEWFHN1cHBv
cnRAbm9yb3V0aW5lLm1lMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA
3AE8UKnG0kNj1fL/9lB9cRS8huGqaL2Cf70Jqk9PC6WbbWEESnDNlk0+foyRcGRU
zpa6OcAKRJE+x73dOV/DEcPq3i/3IYWMiDUuFoVwh2yvsVFiDuL62/iN2T/va5ZY
EzYkXgyDu26Y3w1cKs0oQ7AxEc5AsNTFrLFjwJJZqKF3SBBT9v4H1T0k0Ja+m2Rf
FTj39TQjVJ0F5Gqer96tlWTAL9f4EXV+hwyxfDcYwL5RRuM36f2t/FcJpyx39+bh
xJQn6YccY1sbZaYRekpq/D5Rleow8rSr2zGjQ8cvC3T5kOXp7FtPUfKKfCfXliUM
3j3tvQYuhjH0sImQQJdoKtR17GMUVBK65XV5p4Qu0Ng1AgbseIrQmbP5kec0CXpl
vDiRvx9nqAEQs/neRyufINUNe6k/iqwrT05lJuSwP4zHUoSJqWrPVPQNkqG2CBsY
P8IEWwO1Nuad9CXYI7HPl0LSDXDKGxOsbu1CnGfbNsYOZAGBOL8OuT5kqiWKVWSZ
ptWoe8MB4zIV2tTh0ZUwnpUabTV/4e+quXaX3qB4TnPVSX4CbsqCWb3DbVBFZzFv
Csl3kVtVR/f6qP8LmeZRgS3McKTocPjsBXuTFh/rNsTWPER57ro2mmxpC2Ii50ub
8Y5T0atbDo4+o1Ie8vUYQZ6eJ2csE68NyRYrNnfGcLkCAwEAAaNjMGEwHQYDVR0O
BBYEFNbcGzPQMNNIJJuVQqAMvU5SyEOyMB8GA1UdIwQYMBaAFNbcGzPQMNNIJJuV
QqAMvU5SyEOyMA8GA1UdEwEB/wQFMAMBAf8wDgYDVR0PAQH/BAQDAgGGMA0GCSqG
SIb3DQEBCwUAA4ICAQBfNlE5of8IchAYROo+Sd8NXJzUBT0Rfi1HDo6HfRljlnxD
DkKfV1927V9DCanETSwRQbMakEuTct+kp9wQ6yy/3IgCrLGsx+9eecyZb0MLUxj0
aD2KBlIoqf8ls4fmzxrG7BbWgIQoPQnW75mznQpFff5YcTsFPYjBuxKivNcbY7/i
pLK1y3gUu80zpOOnxPnciGSszvXQDcP6v1hcJcMtd6e/YrZyu+rOz9a/u1Es7IkR
BpA6yk9u/G5k1ZINCw82XBaLX24D71fVcZyyFS82mv1uaNFDOq3hXQQkeYhgxmp+
pfpJpl1FcILKzKba+0+MbST7uqPhzlz8hX6bxbRPbdcdCno6MS0+/2vA48zb47RX
aBmZGA/cYg00IH4gJ7+2gN7DnfJgKzmdJmm/Zj0feYWVj+9SgzhmxjH8v26VJo0H
4rx1oLnsQs0t5cnut9iSA1OljC8Z+Lk+CCYSfTf2o8z64F797xBsLzX7xXRm1y6t
PVS6WXxw6RpYSKjezTpv+4+pUtAEYsIxK/fN2O6S0ptUc5Zc5EY2J0cHmJK5hByu
NPSHQuKYckNxm9BHlepFKixOov9DGHoF2/fPvpoCyvlb386F6fWXq5BxD36BcN7z
wOjE4ursRkg9K+bDBY6lWhPq1wMlI5fYhjZIKfK/6W8r/1g1pgphk7xBFOc3fg==
-----END CERTIFICATE-----
NOROUTINE_ROOT_CA

cat << NOROUTINE_TRUSTED_CA > ${CA_CERTS_DIR}/noroutine-trusted.crt
-----BEGIN CERTIFICATE-----
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
iSEzh0Nw32wEpWOXI/ZDEL7uUzjHSabA9WtC
-----END CERTIFICATE-----
NOROUTINE_TRUSTED_CA

update-ca-certificates

cat << SOURCES >> /etc/apt/sources.list.d/noroutine.list
deb https://twix.noroutine.me/apt/bootstrap stretch main
SOURCES

cat <<NOROUTINEREPO | apt-key add -
-----BEGIN PGP PUBLIC KEY BLOCK-----

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
h5Ahs1lm96hr0bgXBWGF6oRUBi93bKyyBg==
=+uWO
-----END PGP PUBLIC KEY BLOCK-----
NOROUTINEREPO

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