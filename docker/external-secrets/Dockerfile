ARG DOCKER_HUB
ARG INFRA_VERSION
ARG INFRA_NAMESPACE
ARG EXTERNAL_SECRETS_VERSION

FROM ${DOCKER_HUB}/external-secrets/external-secrets:${EXTERNAL_SECRETS_VERSION} AS binary

FROM ${DOCKER_HUB}/${INFRA_NAMESPACE}/alpine:${INFRA_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"

COPY --from=binary /bin/external-secrets /bin/external-secrets

USER 65534

ENTRYPOINT ["/bin/external-secrets"]
