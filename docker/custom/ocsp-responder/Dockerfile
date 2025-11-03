ARG IMAGE_REGISTRY=cr.nrtn.dev
ARG INFRA_NAMESPACE=infra-dev
ARG INFRA_VERSION=dev

FROM ${IMAGE_REGISTRY}/${INFRA_NAMESPACE}/noroutine-ca:${INFRA_VERSION} AS rootca

FROM ${IMAGE_REGISTRY}/${INFRA_NAMESPACE}/alpine:${INFRA_VERSION}

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
