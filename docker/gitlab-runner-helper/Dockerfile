ARG DOCKER_HUB
ARG GITLAB_RUNNER_HELPER_VERSION
ARG INFRA_VERSION
ARG INFRA_NAMESPACE

# FROM ${DOCKER_HUB}/${INFRA_NAMESPACE}/noroutine-ca:${INFRA_VERSION} as rootca

FROM ${DOCKER_HUB}/gitlab-org/gitlab-runner/gitlab-runner-helper:${GITLAB_RUNNER_HELPER_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"

# Noroutine CA certs
# For alpine we should not use subfolders
# COPY --from=rootca /noroutine/ /usr/local/share/ca-certificates/noroutine
# RUN update-ca-certificates
