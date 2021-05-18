ARG DOCKER_HUB
ARG GITLAB_RUNNER_VERSION

FROM ${DOCKER_HUB}/gitlab/gitlab-runner:${GITLAB_RUNNER_VERSION}

MAINTAINER Noroutine GmbH <info@noroutine.me>

ADD cacerts.pem /usr/local/share/ca-certificates/ca.crt