ARG DOCKER_HUB
ARG INFRA_VERSION
ARG INFRA_NAMESPACE
ARG BINDERHUB_VERSION

FROM ${DOCKER_HUB}/${INFRA_NAMESPACE}/noroutine-ca:${INFRA_VERSION} as rootca

FROM ${DOCKER_HUB}/noroutine/k8s-binderhub:${BINDERHUB_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"

# full bundle of CA certs set from Mozilla + Noroutine CA certs
COPY --from=rootca /noroutine /usr/local/share/ca-certificates/noroutine
USER 0
RUN update-ca-certificates

# Certifi CA certs
RUN cp /etc/ssl/certs/ca-certificates.crt /usr/local/lib/python3.11/site-packages/certifi/cacert.pem && \
  cp /etc/ssl/certs/ca-certificates.crt /usr/local/lib/python3.11/site-packages/pip/_vendor/certifi/cacert.pem && \
  cp /etc/ssl/certs/ca-certificates.crt /usr/local/lib/python3.11/site-packages/websocket/cacert.pem

# Python SSL env vars
ENV SSL_CERT_DIR=/etc/ssl/certs
ENV REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
