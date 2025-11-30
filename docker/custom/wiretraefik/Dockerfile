ARG IMAGE_REGISTRY=cr.noroutine.me
ARG WIREGUARD_VERSION=dev
ARG TRAEFIK_VERSION=dev

FROM ${IMAGE_REGISTRY}/library/traefik:${TRAEFIK_VERSION} AS traefik

FROM ${IMAGE_REGISTRY}/masipcat/wireguard-go:${WIREGUARD_VERSION}

COPY --from=traefik /usr/local/bin/traefik /usr/local/bin/traefik

# Install needed packages
RUN apk add --no-cache --no-progress \
  bash curl openssl ca-certificates tzdata ip6tables tcpdump

COPY entrypoint.sh /entrypoint.sh

CMD ["/entrypoint.sh"]
