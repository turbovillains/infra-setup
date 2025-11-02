#!/bin/bash

# Docker style, used by most
ARCHX=$(uname -m | sed 's/aarch64/arm64/;s/x86_64/amd64/')

# Used by crane
ARCHY=$(uname -m | sed 's/aarch64/arm64/')

# Plane linux arch, used by goreleaser
ARCHZ=$(uname -m)

set -e

# kubectl
curl -sLo /usr/local/bin/kubectl "https://dl.k8s.io/release/$(curl -sL https://dl.k8s.io/release/stable.txt)/bin/linux/${ARCHX}/kubectl" && chmod +x /usr/local/bin/kubectl

# jq
# https://github.com/stedolan/jq/releases
# no jq so cannot use JQ_VERSION=$(curl -s "https://api.github.com/repos/jqlang/jq/releases/latest" | jq -r '.tag_name')
JQ_VERSION=jq-1.8.1
curl -sLo /usr/local/bin/jq https://github.com/jqlang/jq/releases/download/${JQ_VERSION}/jq-linux-${ARCHX} && chmod +x /usr/local/bin/jq

# cosign
# https://github.com/sigstore/cosign/releases
curl -sLO "https://github.com/sigstore/cosign/releases/latest/download/cosign-linux-${ARCHX}"
mv cosign-linux-${ARCHX} /usr/local/bin/cosign
chmod +x /usr/local/bin/cosign

# syft
# https://github.com/anchore/syft/releases
curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin

# crane
curl -sLo- "https://github.com/google/go-containerregistry/releases/download/$(curl -s "https://api.github.com/repos/google/go-containerregistry/releases/latest" | jq -r '.tag_name')/go-containerregistry_Linux_${ARCHY}.tar.gz" | tar -C /usr/local/bin/ --no-same-owner -xzv crane krane gcrane

# trivy
# https://github.com/aquasecurity/trivy/releases
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin latest

# pack
# https://github.com/buildpacks/pack/releases
PACK_VERSION=$(curl -s "https://api.github.com/repos/buildpacks/pack/releases/latest" | jq -r '.tag_name')
(curl -sSL "https://github.com/buildpacks/pack/releases/download/${PACK_VERSION}/pack-${PACK_VERSION}-linux.tgz" | tar -C /usr/local/bin/ --no-same-owner -xzv pack)

# helm
# https://github.com/helm/helm/releases
HELM_VERSION=$(curl -s "https://api.github.com/repos/helm/helm/releases/latest" | jq -r '.tag_name')
(curl -sSL "https://get.helm.sh/helm-${HELM_VERSION}-linux-${ARCHX}.tar.gz" | tar -C /usr/local/bin/ --no-same-owner --strip-components=1 -xzv linux-${ARCHX}/helm)

# skaffold
# https://github.com/GoogleContainerTools/skaffold/releases
SKAFFOLD_VERSION=$(curl -s "https://api.github.com/repos/GoogleContainerTools/skaffold/releases/latest" | jq -r '.tag_name')
curl -sLo /usr/local/bin/skaffold https://storage.googleapis.com/skaffold/releases/${SKAFFOLD_VERSION}/skaffold-linux-${ARCHX} && chmod +x /usr/local/bin/skaffold

# yq
# https://github.com/mikefarah/yq/releases
YQ_VERSION=$(curl -s "https://api.github.com/repos/mikefarah/yq/releases/latest" | jq -r '.tag_name')
curl -sLo /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_${ARCHX} && chmod +x /usr/local/bin/yq

# yj
# https://github.com/sclevine/yj/releases
YJ_VERSION=$(curl -s "https://api.github.com/repos/sclevine/yj/releases/latest" | jq -r '.tag_name')
curl -sLo /usr/local/bin/yj https://github.com/sclevine/yj/releases/download/${YJ_VERSION}/yj-linux-${ARCHX} && chmod +x /usr/local/bin/yj

# ytt
# https://github.com/carvel-dev/ytt/releases
YTT_VERSION=$(curl -s "https://api.github.com/repos/carvel-dev/ytt/releases/latest" | jq -r '.tag_name')
curl -sLo /usr/local/bin/ytt https://github.com/carvel-dev/ytt/releases/download/${YTT_VERSION}/ytt-linux-${ARCHX} && chmod +x /usr/local/bin/ytt

# kustomize
# https://github.com/kubernetes-sigs/kustomize/releases
KUSTOMIZE_VERSION=$(curl -s "https://api.github.com/repos/kubernetes-sigs/kustomize/releases/latest" | jq -r '.tag_name' | sed 's/kustomize\///')
(curl -sSL "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_${ARCHX}.tar.gz" | tar -C /usr/local/bin/ --no-same-owner -xzv kustomize)

# argocd
# https://github.com/argoproj/argo-cd/releases
ARGOCD_VERSION=$(curl -s "https://api.github.com/repos/argoproj/argo-cd/releases/latest" | jq -r '.tag_name')
curl -sLo /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/${ARGOCD_VERSION}/argocd-linux-${ARCHX} && chmod +x /usr/local/bin/argocd

# https://github.com/goreleaser/goreleaser/releases
GORELEASER_VERSION=$(curl -s "https://api.github.com/repos/goreleaser/goreleaser/releases/latest" | jq -r '.tag_name' | sed 's/v//')
curl -sLo- https://github.com/goreleaser/goreleaser/releases/download/v${GORELEASER_VERSION}/goreleaser-${GORELEASER_VERSION}-1-${ARCHZ}.pkg.tar.zst \
  | tar -C /usr/local/bin/ --no-same-owner --strip-components=2 --use-compress-program=unzstd -xv usr/bin/goreleaser

# terraform
# https://releases.hashicorp.com/terraform
TERRAFORM_VERSION=$(curl -s "https://api.github.com/repos/hashicorp/terraform/releases/latest" | jq -r '.tag_name' | sed 's/v//')
curl -sLo terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${ARCHX}.zip
unzip terraform.zip
chmod +x terraform
mv terraform /usr/local/bin/terraform
rm terraform.zip

# cfssl
# https://github.com/cloudflare/cfssl/releases
CFSSL_VERSION=$(curl -s "https://api.github.com/repos/cloudflare/cfssl/releases/latest" | jq -r '.tag_name' | sed 's/v//')
curl -sLo /usr/local/bin/cfssl https://github.com/cloudflare/cfssl/releases/download/v${CFSSL_VERSION}/cfssl_${CFSSL_VERSION}_linux_${ARCHX} && chmod +x /usr/local/bin/cfssl

# dagger
curl -fsSL https://dl.dagger.io/dagger/install.sh | BIN_DIR=/usr/local/bin sh


chmod +x /usr/local/bin/*