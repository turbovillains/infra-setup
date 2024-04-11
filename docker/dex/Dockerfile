ARG DOCKER_HUB
ARG INFRA_VERSION
ARG INFRA_NAMESPACE
ARG DEX_VERSION

FROM ${DOCKER_HUB}/${INFRA_NAMESPACE}/noroutine-ca:${INFRA_VERSION} as rootca

FROM ${DOCKER_HUB}/dexidp/dex:${DEX_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"

# full bundle of CA certs set from Mozilla + Noroutine CA certs
USER 0
RUN apk update && apk add ca-certificates && rm -rf /var/cache/apk/*
COPY --from=rootca /noroutine /usr/local/share/ca-certificates
RUN update-ca-certificates
