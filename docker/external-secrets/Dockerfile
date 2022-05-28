ARG DOCKER_HUB
ARG INFRA_VERSION
ARG EXTERNAL_SECRETS_VERSION

FROM ${DOCKER_HUB}/external-secrets/external-secrets:${EXTERNAL_SECRETS_VERSION} as binary

FROM ${DOCKER_HUB}/infra/alpine:${INFRA_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.me>"

COPY --from=binary /bin/external-secrets /bin/external-secrets

USER 65534

ENTRYPOINT ["/bin/external-secrets"]