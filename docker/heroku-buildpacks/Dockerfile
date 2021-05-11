ARG DOCKER_HUB

FROM ${DOCKER_HUB}/heroku/buildpacks:20

MAINTAINER Noroutine GmbH <info@noroutine.me>

USER root

RUN mkdir -p /usr/local/share/ca-certificates/noroutine
ADD https://bo01-vm-nexus01.node.bo01.noroutine.me/repository/noroutine-ca/noroutine-root-ca.crt.pem /usr/local/share/ca-certificates/noroutine/noroutine-root.crt
ADD https://bo01-vm-nexus01.node.bo01.noroutine.me/repository/noroutine-ca/noroutine-trusted-ca.crt.pem /usr/local/share/ca-certificates/noroutine/noroutine-trusted.crt
RUN update-ca-certificates

USER heroku