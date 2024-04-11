ARG DOCKER_HUB
ARG POSTGREST_VERSION
ARG INFRA_VERSION
ARG INFRA_NAMESPACE

FROM ${DOCKER_HUB}/postgrest/postgrest:${POSTGREST_VERSION} as postgrest

FROM ${DOCKER_HUB}/${INFRA_NAMESPACE}/noroutine-ca:${INFRA_VERSION} as rootca

FROM ${DOCKER_HUB}/${INFRA_NAMESPACE}/alpine:${INFRA_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"

USER 0

RUN apk update && apk add --no-cache bash curl openssl ca-certificates && rm -rf /var/cache/apk/*
# full bundle of CA certs set from Mozilla + Noroutine CA certs
# For alpine we should not use subfolders
COPY --from=rootca /noroutine/ /usr/local/share/ca-certificates
RUN update-ca-certificates

COPY --from=postgrest /bin/postgrest /usr/bin

USER 1000

EXPOSE 3000

CMD [ "/bin/bin/postgrest" ]
