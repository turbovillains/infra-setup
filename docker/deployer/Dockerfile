ARG DOCKER_HUB
ARG UBUNTU_VERSION
FROM ${DOCKER_HUB}/ubuntu:${UBUNTU_VERSION}

MAINTAINER Noroutine UG <info@noroutine.me>

ADD setup /setup

RUN /setup/provision.sh