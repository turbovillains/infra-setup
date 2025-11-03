ARG IMAGE_REGISTRY=cr.nrtn.dev
ARG ALPINE_VERSION=dev
ARG EXTERNAL_SECRETS_VERSION=dev

FROM ${IMAGE_REGISTRY}/external-secrets/external-secrets:${EXTERNAL_SECRETS_VERSION} AS binary

FROM ${IMAGE_REGISTRY}/library/alpine:${ALPINE_VERSION}

COPY --from=binary /bin/external-secrets /bin/external-secrets

USER 65534

ENTRYPOINT ["/bin/external-secrets"]
