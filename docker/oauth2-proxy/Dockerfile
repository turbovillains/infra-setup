ARG DOCKER_HUB
ARG OAUTH2_PROXY_VERSION
ARG INFRA_VERSION

FROM ${DOCKER_HUB}/infra/noroutine-ca:${INFRA_VERSION} as rootca

FROM ${DOCKER_HUB}/oauth2-proxy/oauth2-proxy:${OAUTH2_PROXY_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.me>"

USER 0
RUN apk update && apk add --no-cache ca-certificates && rm -rf /var/cache/apk/*
# full bundle of CA certs set from Mozilla + Noroutine CA certs
# For alpine we should not use subfolders
COPY --from=rootca /noroutine/ /usr/local/share/ca-certificates/noroutine
RUN update-ca-certificates
USER 2000