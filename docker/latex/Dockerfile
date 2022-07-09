ARG DOCKER_HUB
ARG LATEX_BASE

FROM ${DOCKER_HUB}/${LATEX_BASE}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -q && apt-get install -qy \
    curl jq \
    texlive-full \
    python-pygments gnuplot \
    make git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /data
VOLUME ["/data"]