ARG DOCKER_HUB
ARG INFRA_VERSION
ARG INFRA_NAMESPACE
ARG HASURA_GRAPHQL_VERSION

FROM ${DOCKER_HUB}/${INFRA_NAMESPACE}/noroutine-ca:${INFRA_VERSION} as rootca

FROM ${DOCKER_HUB}/hasura/graphql-engine:${HASURA_GRAPHQL_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"

# Noroutine CA certs
COPY --from=rootca /noroutine /usr/local/share/ca-certificates/noroutine
RUN update-ca-certificates
