ARG DOCKER_HUB
ARG INFRA_VERSION
ARG BOKY_POSTFIX_VERSION

FROM ${DOCKER_HUB}/infra/noroutine-ca:${INFRA_VERSION} as rootca

FROM ${DOCKER_HUB}/boky/postfix:${BOKY_POSTFIX_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.me>"

# full bundle of CA certs set from Mozilla + Noroutine CA certs
USER 0
RUN apk update && apk add ca-certificates && rm -rf /var/cache/apk/*
COPY --from=rootca /noroutine /usr/local/share/ca-certificates
RUN update-ca-certificates
