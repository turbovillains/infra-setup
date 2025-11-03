ARG IMAGE_REGISTRY=cr.nrtn.dev
ARG INFRA_NAMESPACE=infra-dev
ARG INFRA_VERSION=dev
ARG WIREGUARD_VERSION=dev
ARG TRAEFIK_VERSION=dev

FROM ${IMAGE_REGISTRY}/${INFRA_NAMESPACE}/noroutine-ca:${INFRA_VERSION} AS rootca

FROM ${IMAGE_REGISTRY}/library/traefik:${TRAEFIK_VERSION} AS traefik

FROM ${IMAGE_REGISTRY}/masipcat/wireguard-go:${WIREGUARD_VERSION}

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
