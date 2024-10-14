ARG DOCKER_HUB
ARG WIREGUARD_VERSION
ARG TRAEFIK_VERSION
ARG INFRA_VERSION
ARG INFRA_NAMESPACE

FROM ${DOCKER_HUB}/${INFRA_NAMESPACE}/noroutine-ca:${INFRA_VERSION} AS rootca

FROM ${DOCKER_HUB}/library/traefik:${TRAEFIK_VERSION} AS traefik

FROM ${DOCKER_HUB}/masipcat/wireguard-go:${WIREGUARD_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"

COPY --from=traefik /usr/local/bin/traefik /usr/local/bin/traefik

# Install needed packages
RUN apk add --no-cache --no-progress \
  bash curl openssl ca-certificates tzdata ip6tables tcpdump

# full bundle of CA certs set from Mozilla + Noroutine CA certs
# For alpine we should not use subfolders
COPY --from=rootca /noroutine/ /usr/local/share/ca-certificates
RUN update-ca-certificates

COPY entrypoint.sh /entrypoint.sh

CMD ["/entrypoint.sh"]
