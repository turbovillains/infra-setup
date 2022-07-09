ARG DOCKER_HUB
ARG STRAPI_VERSION
ARG INFRA_VERSION

FROM ${DOCKER_HUB}/infra/noroutine-ca:${INFRA_VERSION} as rootca

FROM ${DOCKER_HUB}/strapi/strapi:${STRAPI_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"

RUN apk update && apk add ca-certificates && rm -rf /var/cache/apk/*

# full bundle of CA certs set from Mozilla + Noroutine CA certs
# For alpine we should not use subfolders
COPY --from=rootca /noroutine/ /usr/local/share/ca-certificates
RUN update-ca-certificates