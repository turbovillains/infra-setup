ARG DOCKER_HUB
ARG INFRA_VERSION
ARG INFRA_NAMESPACE

FROM ${DOCKER_HUB}/${INFRA_NAMESPACE}/noroutine-ca:${INFRA_VERSION} as rootca

FROM ${DOCKER_HUB}/${INFRA_NAMESPACE}/ubuntu22:${INFRA_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"

# full bundle of CA certs set from Mozilla + Noroutine CA certs, setup will run the update
COPY --from=rootca /noroutine /usr/local/share/ca-certificates/noroutine

# ENV ALL_PROXY=${HTTP_PROXY} \
#   http_proxy=${HTTP_PROXY} \
#   HTTP_PROXY=${HTTP_PROXY} \
#   https_proxy=${HTTPS_PROXY}} \
#   HTTPS_PROXY=${HTTPS_PROXY}} \
#   NO_PROXY=${NO_PROXY}} \
#   no_proxy=${NO_PROXY}}

COPY setup.sh /tmp/setup.sh
RUN /tmp/setup.sh
