ARG DOCKER_HUB
ARG INFRA_VERSION
ARG INFRA_NAMESPACE

FROM ${DOCKER_HUB}/${INFRA_NAMESPACE}/noroutine-ca:${INFRA_VERSION} AS rootca

FROM ${DOCKER_HUB}/${INFRA_NAMESPACE}/alpine:${INFRA_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"

USER 0
RUN apk update && apk add --no-cache bash curl openssl ca-certificates && rm -rf /var/cache/apk/*
# full bundle of CA certs set from Mozilla + Noroutine CA certs
# For alpine we should not use subfolders
COPY --from=rootca /noroutine/ /usr/local/share/ca-certificates
RUN update-ca-certificates

ENV OCSP_PORT=8080
EXPOSE ${OCSP_PORT}

ADD docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT [ "/docker-entrypoint.sh" ]
