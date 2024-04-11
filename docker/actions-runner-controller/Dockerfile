ARG DOCKER_HUB
ARG ACTIONS_RUNNER_CONTROLLER_VERSION
ARG INFRA_VERSION
ARG INFRA_NAMESPACE

FROM ${DOCKER_HUB}/${INFRA_NAMESPACE}/noroutine-ca:${INFRA_VERSION} as rootca

FROM ${DOCKER_HUB}/summerwind/actions-runner-controller:${ACTIONS_RUNNER_CONTROLLER_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"
