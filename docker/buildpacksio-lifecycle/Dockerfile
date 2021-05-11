ARG DOCKER_HUB
ARG BUILDPACKSIO_LIFECYCLE_VERSION

FROM ${DOCKER_HUB}/buildpacksio/lifecycle:${BUILDPACKSIO_LIFECYCLE_VERSION}

MAINTAINER Noroutine GmbH <info@noroutine.me>

# full bundle of CA certs set from Mozilla + Noroutine CA certs
ADD cacerts.pem /etc/ssl/certs/ca-certificates.crt