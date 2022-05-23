ARG DOCKER_HUB
ARG ACTIONS_RUNNER_CONTROLLER_VERSION
ARG INFRA_VERSION

FROM ${DOCKER_HUB}/infra/noroutine-ca:${INFRA_VERSION} as rootca

FROM ${DOCKER_HUB}/summerwind/actions-runner-controller:${ACTIONS_RUNNER_CONTROLLER_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.me>"

# Todo: Noroutine CA certs
# COPY --from=rootca /noroutine /usr/local/share/ca-certificates/noroutine
# RUN update-ca-certificates
