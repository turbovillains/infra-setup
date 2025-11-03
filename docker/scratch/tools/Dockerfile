ARG IMAGE_REGISTRY=cr.nrtn.dev
ARG DEBIAN_VERSION=dev

FROM ${IMAGE_REGISTRY}/library/debian:${DEBIAN_VERSION} AS download

USER 0

RUN apt-get update && apt-get install -y \
  gnupg2 curl ca-certificates \
  && rm -rf /var/lib/apt/lists/*

ADD setup.sh /setup.sh
RUN /setup.sh

FROM scratch

COPY --from=download /usr/local/bin /usr/local/bin
