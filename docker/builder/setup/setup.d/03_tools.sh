#!/bin/bash

# kubectl
sudo curl -Lo /usr/local/bin/kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && sudo chmod +x /usr/local/bin/kubectl

# jq
# https://github.com/stedolan/jq/releases
sudo curl -sLo /usr/local/bin/jq https://github.com/stedolan/jq/releases/download/jq-1.7.1/jq-linux64 && sudo chmod +x /usr/local/bin/jq

# crane
curl -sLo- "https://github.com/google/go-containerregistry/releases/download/$(curl -s "https://api.github.com/repos/google/go-containerregistry/releases/latest" | jq -r '.tag_name')/go-containerregistry_linux_x86_64.tar.gz" | sudo tar -C /usr/local/bin/ --no-same-owner -xzv crane krane gcrane

# trivy
# https://github.com/aquasecurity/trivy/releases
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sudo sh -s -- -b /usr/local/bin latest

# pack
# https://github.com/buildpacks/pack/releases
(curl -sSL "https://github.com/buildpacks/pack/releases/download/v0.33.2/pack-v0.33.2-linux.tgz" | sudo tar -C /usr/local/bin/ --no-same-owner -xzv pack)

# helm
# https://github.com/helm/helm/releases
(curl -sSL "https://get.helm.sh/helm-v3.15.0-linux-amd64.tar.gz" | sudo tar -C /usr/local/bin/ --no-same-owner --strip-components=1 -xzv linux-amd64/helm)

# skaffold
# https://github.com/GoogleContainerTools/skaffold/releases
sudo curl -sLo /usr/local/bin/skaffold https://storage.googleapis.com/skaffold/releases/v2.12.0/skaffold-linux-amd64 && sudo chmod +x /usr/local/bin/skaffold

# yq
# https://github.com/mikefarah/yq/releases
sudo curl -sLo /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/v4.44.1/yq_linux_amd64 && sudo chmod +x /usr/local/bin/yq

# yj
# https://github.com/sclevine/yj/releases
sudo curl -sLo /usr/local/bin/yj https://github.com/sclevine/yj/releases/download/v5.1.0/yj-linux-amd64 && sudo chmod +x /usr/local/bin/yj


# ytt
# https://github.com/vmware-tanzu/carvel-ytt/releases
sudo curl -sLo /usr/local/bin/ytt https://github.com/vmware-tanzu/carvel-ytt/releases/download/v0.49.0/ytt-linux-amd64 && sudo chmod +x /usr/local/bin/ytt

# kustomize
# https://github.com/kubernetes-sigs/kustomize/releases
(curl -sSL "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv5.4.2/kustomize_v5.4.2_linux_amd64.tar.gz" | sudo tar -C /usr/local/bin/ --no-same-owner -xzv kustomize)

# argocd
# https://github.com/argoproj/argo-cd/releases
sudo curl -sLo /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/v2.11.2/argocd-linux-amd64 && sudo chmod +x /usr/local/bin/argocd

# argo workflows
# https://github.com/argoproj/argo-workflows/releases
curl -sLo argocli.gz https://github.com/argoproj/argo-workflows/releases/download/v3.5.6/argo-linux-amd64.gz
gunzip argocli.gz
sudo mv argocli /usr/local/bin/argocli

# https://github.com/goreleaser/goreleaser/releases
curl -sLo- https://github.com/goreleaser/goreleaser/releases/download/v1.26.1/goreleaser-1.26.1-1-x86_64.pkg.tar.zst \
  | sudo tar -C /usr/local/bin/ --no-same-owner --strip-components=2 --use-compress-program=unzstd -xv usr/bin/goreleaser

# terraform
# https://releases.hashicorp.com/terraform
curl -sLo terraform.zip https://releases.hashicorp.com/terraform/1.8.4/terraform_1.8.4_linux_amd64.zip
unzip terraform.zip
chmod +x terraform
sudo mv terraform /usr/local/bin/terraform
rm terraform.zip

# cfssl
curl -sLo /usr/local/bin/cfssl https://github.com/cloudflare/cfssl/releases/download/v1.6.5/cfssl_1.6.5_linux_amd64 && sudo chmod +x /usr/local/bin/cfssl

# brew install nvm

# consul nomad vault envconsul consul-template
# hey
# ko crane
# k9s kubectx
# instrumenta/instrumenta/kubeval
# dty1er/tap/kubecolor
# cosign
