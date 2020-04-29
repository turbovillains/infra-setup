ARG DOCKER_HUB
FROM ${DOCKER_HUB}/debian:10.3-slim

MAINTAINER Noroutine UG <info@noroutine.me>

ARG GIT_SERVER_HOST
ARG SSH_PRIVATE_KEY

ADD sources.list /etc/apt/sources.list

ADD requirements.txt /requirements.txt
ADD setup.sh /setup.sh
ADD setup.d /setup.d

ENV GIT_SERVER_HOST=${GIT_SERVER_HOST}
ENV SSH_PRIVATE_KEY=${SSH_PRIVATE_KEY}

RUN /setup.sh