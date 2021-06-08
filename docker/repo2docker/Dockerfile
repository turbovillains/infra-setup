ARG DOCKER_HUB
ARG INFRA_VERSION
ARG REPO2DOCKER_VERSION

FROM ${DOCKER_HUB}/infra/noroutine-ca:${INFRA_VERSION} as rootca

FROM ${DOCKER_HUB}/jupyter/repo2docker:${REPO2DOCKER_VERSION}

MAINTAINER Noroutine GmbH <info@noroutine.me>

# full bundle of CA certs set from Mozilla + Noroutine CA certs
COPY --from=rootca /noroutine /usr/local/share/ca-certificates/noroutine
RUN update-ca-certificates
