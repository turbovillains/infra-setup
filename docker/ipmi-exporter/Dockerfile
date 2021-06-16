ARG DOCKER_HUB
ARG DEBIAN_VERSION
ARG IPMI_EXPORTER_VERSION

FROM ${DOCKER_HUB}/golang:1.14-alpine

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.me>"

RUN apk --no-cache add git

ENV CGO_ENABLED 0
ENV GOARCH amd64

RUN go get -d github.com/soundcloud/ipmi_exporter \
    && cd /go/src/github.com/soundcloud/ipmi_exporter \
    && git checkout ${IPMI_EXPORTER_VERSION} \
    && go install

FROM ${DOCKER_HUB}/debian:${DEBIAN_VERSION}

COPY --from=0 /go/bin/ipmi_exporter /ipmi-exporter

RUN apt-get update && \
    apt-get install freeipmi-tools --no-install-recommends -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

EXPOSE 9290
ENTRYPOINT [ "/ipmi-exporter" ]