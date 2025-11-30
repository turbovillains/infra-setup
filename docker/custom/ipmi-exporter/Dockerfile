ARG IMAGE_REGISTRY=cr.noroutine.me
ARG DEBIAN_VERSION=dev
ARG GOLANG_VERSION=dev
ARG IPMI_EXPORTER_VERSION=dev

FROM ${IMAGE_REGISTRY}/library/golang:${GOLANG_VERSION} AS builder

ARG TARGETARCH

RUN apt-get update && \
    apt-get install git make curl gcc build-essential --no-install-recommends -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ENV CGO_ENABLED=0
ENV GOARCH=${TARGETARCH}
ENV CGO_ENABLED=1

RUN cd / \
    && git clone https://github.com/soundcloud/ipmi_exporter \
    && cd ipmi_exporter \
    && git checkout ${IPMI_EXPORTER_VERSION} \
    && make

FROM ${IMAGE_REGISTRY}/library/debian:${DEBIAN_VERSION}

COPY --from=builder /ipmi_exporter/ipmi_exporter /ipmi-exporter

RUN apt-get update && \
    apt-get install freeipmi-tools --no-install-recommends -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

EXPOSE 9290
ENTRYPOINT [ "/ipmi-exporter" ]
