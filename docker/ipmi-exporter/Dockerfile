ARG DOCKER_HUB
ARG INFRA_VERSION
ARG INFRA_NAMESPACE
ARG IPMI_EXPORTER_VERSION
ARG GOLANG_VERSION

FROM ${DOCKER_HUB}/library/golang:${GOLANG_VERSION} as builder

ARG TARGETARCH

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"

RUN apt-get update && \
    apt-get install git make curl gcc build-essential --no-install-recommends -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ENV CGO_ENABLED 0
ENV GOARCH ${TARGETARCH}
ENV CGO_ENABLED 1

RUN cd / \
    && git clone https://github.com/soundcloud/ipmi_exporter \
    && cd ipmi_exporter \
    && git checkout ${IPMI_EXPORTER_VERSION} \
    && make

FROM ${DOCKER_HUB}/${INFRA_NAMESPACE}/debian:${INFRA_VERSION}

COPY --from=builder /ipmi_exporter/ipmi_exporter /ipmi-exporter

RUN apt-get update && \
    apt-get install freeipmi-tools --no-install-recommends -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

EXPOSE 9290
ENTRYPOINT [ "/ipmi-exporter" ]
