ARG DOCKER_HUB
ARG STACK_BASE
ARG INFRA_VERSION

FROM ${DOCKER_HUB}/infra/noroutine-ca:${INFRA_VERSION} as rootca

FROM ${DOCKER_HUB}/${STACK_BASE}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.me>"

# full bundle of CA certs set from Mozilla + Noroutine CA certs, setup will run the update
COPY --from=rootca /noroutine /usr/local/share/ca-certificates/noroutine

COPY setup.sh /tmp/setup.sh
RUN /tmp/setup.sh
