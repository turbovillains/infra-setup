ARG DOCKER_HUB
ARG STACK_IMAGE

FROM ${DOCKER_HUB}/${STACK_IMAGE}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"

COPY setup.sh /tmp/setup.sh
RUN /tmp/setup.sh
