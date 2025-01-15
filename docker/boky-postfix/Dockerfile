ARG IMAGE_REGISTRY
ARG IMAGE_BASE
ARG IMAGE_VERSION

FROM ${IMAGE_REGISTRY}/${IMAGE_BASE}:${IMAGE_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"

COPY healthcheck.sh /scripts/healthcheck.sh
