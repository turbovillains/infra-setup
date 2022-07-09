ARG DOCKER_HUB
ARG INFRA_VERSION
ARG REPO2DOCKER_VERSION

FROM ${DOCKER_HUB}/infra/noroutine-ca:${INFRA_VERSION} as rootca

FROM ${DOCKER_HUB}/jupyterhub/repo2docker:${REPO2DOCKER_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"

# Noroutine CA certs
# For alpine we should not use subfolders
COPY --from=rootca /noroutine/ /usr/local/share/ca-certificates/noroutine
RUN update-ca-certificates
