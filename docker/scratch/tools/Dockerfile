ARG IMAGE_REGISTRY=cr.nrtn.dev
ARG ALPINE_VERSION=dev

FROM ${IMAGE_REGISTRY}/library/alpine:${ALPINE_VERSION} AS download

USER 0

RUN apk add --no-cache curl bash

ADD setup.sh /setup.sh
RUN /setup.sh

FROM scratch

COPY --from=download /usr/local/bin /usr/local/bin
