ARG DOCKER_HUB
ARG GOLANG_VERSION
ARG DEBIAN_VERSION

FROM ${DOCKER_HUB}/golang:${GOLANG_VERSION}

RUN apt-get update && \
    apt-get install git --no-install-recommends -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN go install github.com/fihuer/ioping_exporter@latest

FROM ${DOCKER_HUB}/debian:${DEBIAN_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.me>"

COPY --from=0 /go/bin/ioping_exporter /ioping-exporter

RUN apt-get update && \
    apt-get install ioping --no-install-recommends -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

EXPOSE 9101
ENTRYPOINT [ "/ioping-exporter" ]