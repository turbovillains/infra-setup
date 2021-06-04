ARG DOCKER_HUB
ARG BINDERHUB_VERSION

FROM ${DOCKER_HUB}/jupyterhub/k8s-binderhub:${BINDERHUB_VERSION}

MAINTAINER Noroutine GmbH <info@noroutine.me>

# full bundle of CA certs set from Mozilla + Noroutine CA certs
ADD cacerts.pem /etc/ssl/certs/ca-certificates.crt
