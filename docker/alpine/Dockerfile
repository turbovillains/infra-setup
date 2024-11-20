ARG DOCKER_HUB
ARG ALPINE_VERSION
ARG INFRA_VERSION
ARG INFRA_NAMESPACE

FROM ${DOCKER_HUB}/${INFRA_NAMESPACE}/noroutine-ca:${INFRA_VERSION} AS rootca

FROM ${DOCKER_HUB}/library/alpine:${ALPINE_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"

RUN apk update && apk add ca-certificates && rm -rf /var/cache/apk/*

# full bundle of CA certs set from Mozilla + Noroutine CA certs
# For alpine we should not use subfolders
COPY --from=rootca /noroutine/ /usr/local/share/ca-certificates
RUN update-ca-certificates
