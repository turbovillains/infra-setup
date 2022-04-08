ARG DOCKER_HUB
ARG INFRA_VERSION
ARG ARGOCD_VERSION

FROM scratch as ytt
ARG YTT_VERSION=v0.40.1

ADD https://github.com/vmware-tanzu/carvel-ytt/releases/download/${YTT_VERSION}/ytt-linux-amd64 /ytt

FROM ${DOCKER_HUB}/infra/noroutine-ca:${INFRA_VERSION} as rootca

FROM ${DOCKER_HUB}/argoproj/argocd:${ARGOCD_VERSION}
ARG YTT_HASH=11222665c627b8f0a1443534a3dde3c9b3aac08b322d28e91f0e011e3aeb7df5

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.me>"

# full bundle of CA certs set from Mozilla + Noroutine CA certs
USER 0
COPY --from=rootca /noroutine /usr/local/share/ca-certificates/noroutine
RUN update-ca-certificates

COPY --from=ytt /ytt /usr/bin/ytt
RUN chmod 0755 /usr/bin/ytt && \
  shasum -a 256 /usr/bin/ytt | grep -q ${YTT_HASH}
