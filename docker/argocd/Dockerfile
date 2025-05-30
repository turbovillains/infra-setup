ARG DOCKER_HUB
ARG INFRA_VERSION
ARG INFRA_NAMESPACE
ARG ARGOCD_VERSION

FROM scratch as ytt
ARG YTT_VERSION=0.40.1
ARG TARGETARCH

ADD https://github.com/vmware-tanzu/carvel-ytt/releases/download/v${YTT_VERSION}/ytt-linux-${TARGETARCH} /ytt

FROM scratch as avp
ARG ARGOCD_VAULT_PLUGIN_VERSION=1.11.0
ARG TARGETARCH

ADD https://github.com/argoproj-labs/argocd-vault-plugin/releases/download/v${ARGOCD_VAULT_PLUGIN_VERSION}/argocd-vault-plugin_${ARGOCD_VAULT_PLUGIN_VERSION}_linux_${TARGETARCH} /argocd-vault-plugin

FROM ${DOCKER_HUB}/${INFRA_NAMESPACE}/noroutine-ca:${INFRA_VERSION} AS rootca

FROM ${DOCKER_HUB}/argoproj/argocd:${ARGOCD_VERSION}
# ARG YTT_HASH=11222665c627b8f0a1443534a3dde3c9b3aac08b322d28e91f0e011e3aeb7df5
# ARG ARGOCD_VAULT_PLUGIN_HASH=307c5f9de016ee62e0e1dce1f6b6e8f5617f345c20b61eae7d2be2a8a8941d98

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"

# full bundle of CA certs set from Mozilla + Noroutine CA certs
USER 0

COPY --from=rootca /noroutine /usr/local/share/ca-certificates/noroutine
RUN update-ca-certificates

COPY --from=ytt /ytt /usr/bin/ytt
RUN chmod 0755 /usr/bin/ytt

COPY --from=avp /argocd-vault-plugin /usr/bin/argocd-vault-plugin
RUN chmod 0755 /usr/bin/argocd-vault-plugin

USER 999
