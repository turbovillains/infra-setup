ARG DOCKER_HUB
ARG INFRA_VERSION
ARG ACTIONS_RUNNER_IMAGE_VERSION

FROM ${DOCKER_HUB}/infra/noroutine-ca:${INFRA_VERSION} as rootca

FROM ${DOCKER_HUB}/summerwind/actions-runner-dind:${ACTIONS_RUNNER_IMAGE_VERSION}

ARG HOST_DOCKER_GID

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"

USER 0
RUN apt-get update && apt-get install -y \
    curl ca-certificates \
  && rm -rf /var/lib/apt/lists/*

COPY --from=rootca /noroutine /usr/local/share/ca-certificates/noroutine
RUN update-ca-certificates

# Should match runner GID
RUN groupmod --gid ${HOST_DOCKER_GID} docker

USER runner