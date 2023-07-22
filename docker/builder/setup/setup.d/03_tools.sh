#!/bin/bash

# kubectl
sudo curl -Lo /usr/local/bin/kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && sudo chmod +x /usr/local/bin/kubectl

# trivy
# https://github.com/aquasecurity/trivy/releases
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sudo sh -s -- -b /usr/local/bin v0.43.1

# pack
# https://github.com/buildpacks/pack/releases
(curl -sSL "https://github.com/buildpacks/pack/releases/download/v0.29.0/pack-v0.29.0-linux.tgz" | sudo tar -C /usr/local/bin/ --no-same-owner -xzv pack)

# helm
# https://github.com/helm/helm/releases
(curl -sSL "https://get.helm.sh/helm-v3.12.2-linux-amd64.tar.gz" | sudo tar -C /usr/local/bin/ --no-same-owner --strip-components=1 -xzv linux-amd64/helm)

# skaffold
# https://github.com/GoogleContainerTools/skaffold/releases
sudo curl -sLo /usr/local/bin/skaffold https://storage.googleapis.com/skaffold/releases/v2.6.2/skaffold-linux-amd64 && sudo chmod +x /usr/local/bin/skaffold

# yq
# https://github.com/mikefarah/yq/releases
sudo curl -sLo /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/v4.34.2/yq_linux_amd64 && sudo chmod +x /usr/local/bin/yq

# yj
# https://github.com/sclevine/yj/releases
sudo curl -sLo /usr/local/bin/yj https://github.com/sclevine/yj/releases/download/v5.1.0/yj-linux-amd64 && sudo chmod +x /usr/local/bin/yj

# jq
# https://github.com/stedolan/jq/releases
sudo curl -sLo /usr/local/bin/jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 && sudo chmod +x /usr/local/bin/jq

# ytt
# https://github.com/vmware-tanzu/carvel-ytt/releases
sudo curl -sLo /usr/local/bin/ytt https://github.com/vmware-tanzu/carvel-ytt/releases/download/v0.45.3/ytt-linux-amd64 && sudo chmod +x /usr/local/bin/ytt

# kustomize
# https://github.com/kubernetes-sigs/kustomize/releases
(curl -sSL "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv5.1.0/kustomize_v5.1.0_linux_amd64.tar.gz" | sudo tar -C /usr/local/bin/ --no-same-owner -xzv kustomize)

# argocd
# https://github.com/argoproj/argo-cd/releases
sudo curl -sLo /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/v2.7.8/argocd-linux-amd64 && sudo chmod +x /usr/local/bin/argocd

# argo workflows
# https://github.com/argoproj/argo-workflows/releases
curl -sLo argocli.gz https://github.com/argoproj/argo-workflows/releases/download/v3.4.9/argo-linux-amd64.gz
gunzip argocli.gz
sudo mv argocli /usr/local/bin/argocli

# https://github.com/goreleaser/goreleaser/releases
curl -sLo- https://github.com/goreleaser/goreleaser/releases/download/v1.19.2/goreleaser-1.19.2-1-x86_64.pkg.tar.zst \
  | sudo tar -C /usr/local/bin/ --no-same-owner --strip-components=2 --use-compress-program=unzstd -xv usr/bin/goreleaser

# terraform
# https://releases.hashicorp.com/terraform
curl -sLo terraform.zip https://releases.hashicorp.com/terraform/1.5.3/terraform_1.5.3_linux_amd64.zip
unzip terraform.zip
chmod +x terraform
sudo mv terraform /usr/local/bin/terraform
rm terraform.zip

# brew install nvm

# consul nomad vault envconsul consul-template
# hey
# ko crane
# k9s kubectx
# instrumenta/instrumenta/kubeval
# dty1er/tap/kubecolor
# cosign
