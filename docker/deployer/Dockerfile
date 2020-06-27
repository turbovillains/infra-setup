ARG DOCKER_HUB
ARG DEPLOYER_BASE
FROM ${DOCKER_HUB}/${DEPLOYER_BASE}

MAINTAINER Noroutine UG <info@noroutine.me>

ADD setup /setup

RUN /setup/provision.sh