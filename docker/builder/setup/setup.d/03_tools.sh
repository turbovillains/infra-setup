#!/bin/bash

# kubectl
sudo curl -Lo /usr/local/bin/kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && sudo chmod +x /usr/local/bin/kubectl

# jq
# https://github.com/stedolan/jq/releases
# no jq so cannot use JQ_VERSION=$(curl -s "https://api.github.com/repos/jqlang/jq/releases/latest" | jq -r '.tag_name')
JQ_VERSION=jq-1.7.1
sudo curl -sLo /usr/local/bin/jq https://github.com/jqlang/jq/releases/download/${JQ_VERSION}/jq-linux64 && sudo chmod +x /usr/local/bin/jq

# cosign
# https://github.com/sigstore/cosign/releases
curl -O -L "https://github.com/sigstore/cosign/releases/latest/download/cosign-linux-amd64"
sudo mv cosign-linux-amd64 /usr/local/bin/cosign
sudo chmod +x /usr/local/bin/cosign

# syft
# https://github.com/anchore/syft/releases
curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin

# crane
curl -sLo- "https://github.com/google/go-containerregistry/releases/download/$(curl -s "https://api.github.com/repos/google/go-containerregistry/releases/latest" | jq -r '.tag_name')/go-containerregistry_linux_x86_64.tar.gz" | sudo tar -C /usr/local/bin/ --no-same-owner -xzv crane krane gcrane

# trivy
# https://github.com/aquasecurity/trivy/releases
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sudo sh -s -- -b /usr/local/bin latest

# pack
# https://github.com/buildpacks/pack/releases
PACK_VERSION=$(curl -s "https://api.github.com/repos/buildpacks/pack/releases/latest" | jq -r '.tag_name')
(curl -sSL "https://github.com/buildpacks/pack/releases/download/${PACK_VERSION}/pack-${PACK_VERSION}-linux.tgz" | sudo tar -C /usr/local/bin/ --no-same-owner -xzv pack)

# helm
# https://github.com/helm/helm/releases
HELM_VERSION=$(curl -s "https://api.github.com/repos/helm/helm/releases/latest" | jq -r '.tag_name')
(curl -sSL "https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz" | sudo tar -C /usr/local/bin/ --no-same-owner --strip-components=1 -xzv linux-amd64/helm)

# skaffold
# https://github.com/GoogleContainerTools/skaffold/releases
SKAFFOLD_VERSION=$(curl -s "https://api.github.com/repos/GoogleContainerTools/skaffold/releases/latest" | jq -r '.tag_name')
sudo curl -sLo /usr/local/bin/skaffold https://storage.googleapis.com/skaffold/releases/${SKAFFOLD_VERSION}/skaffold-linux-amd64 && sudo chmod +x /usr/local/bin/skaffold

# yq
# https://github.com/mikefarah/yq/releases
YQ_VERSION=$(curl -s "https://api.github.com/repos/mikefarah/yq/releases/latest" | jq -r '.tag_name')
sudo curl -sLo /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64 && sudo chmod +x /usr/local/bin/yq

# yj
# https://github.com/sclevine/yj/releases
YJ_VERSION=$(curl -s "https://api.github.com/repos/sclevine/yj/releases/latest" | jq -r '.tag_name')
sudo curl -sLo /usr/local/bin/yj https://github.com/sclevine/yj/releases/download/${YJ_VERSION}/yj-linux-amd64 && sudo chmod +x /usr/local/bin/yj

# ytt
# https://github.com/carvel-dev/ytt/releases
YTT_VERSION=$(curl -s "https://api.github.com/repos/carvel-dev/ytt/releases/latest" | jq -r '.tag_name')
sudo curl -sLo /usr/local/bin/ytt https://github.com/carvel-dev/ytt/releases/download/${YTT_VERSION}/ytt-linux-amd64 && sudo chmod +x /usr/local/bin/ytt

# kustomize
# https://github.com/kubernetes-sigs/kustomize/releases
KUSTOMIZE_VERSION=v5.4.2
(curl -sSL "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_amd64.tar.gz" | sudo tar -C /usr/local/bin/ --no-same-owner -xzv kustomize)

# argocd
# https://github.com/argoproj/argo-cd/releases
ARGOCD_VERSION=v2.11.3
sudo curl -sLo /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/${ARGOCD_VERSION}/argocd-linux-amd64 && sudo chmod +x /usr/local/bin/argocd

# argo workflows
# https://github.com/argoproj/argo-workflows/releases
ARGO_WORKFLOWS_VERSION=v3.5.8
curl -sLo argocli.gz https://github.com/argoproj/argo-workflows/releases/download/${ARGO_WORKFLOWS_VERSION}/argo-linux-amd64.gz
gunzip argocli.gz
sudo mv argocli /usr/local/bin/argocli

# https://github.com/goreleaser/goreleaser/releases
GORELEASER_VERSION=2.0.1
curl -sLo- https://github.com/goreleaser/goreleaser/releases/download/v${GORELEASER_VERSION}/goreleaser-${GORELEASER_VERSION}-1-x86_64.pkg.tar.zst \
  | sudo tar -C /usr/local/bin/ --no-same-owner --strip-components=2 --use-compress-program=unzstd -xv usr/bin/goreleaser

# terraform
# https://releases.hashicorp.com/terraform
TERRAFORM_VERSION=1.8.5
curl -sLo terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
unzip terraform.zip
chmod +x terraform
sudo mv terraform /usr/local/bin/terraform
rm terraform.zip

# cfssl
# https://github.com/cloudflare/cfssl/releases
CFSSL_VERSION=1.6.5
curl -sLo /usr/local/bin/cfssl https://github.com/cloudflare/cfssl/releases/download/v${CFSSL_VERSION}/cfssl_${CFSSL_VERSION}_linux_amd64 && sudo chmod +x /usr/local/bin/cfssl

# brew install nvm

# consul nomad vault envconsul consul-template
# hey
# k9s kubectx
# instrumenta/instrumenta/kubeval
# dty1er/tap/kubecolor
