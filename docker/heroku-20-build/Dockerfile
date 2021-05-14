ARG DOCKER_HUB
ARG STACK_IMAGE

FROM ${DOCKER_HUB}/${STACK_IMAGE}
COPY setup.sh /tmp/setup.sh
RUN /tmp/setup.sh
