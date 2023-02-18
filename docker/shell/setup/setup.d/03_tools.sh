#!/bin/bash

# kubectl
sudo curl -Lo /usr/local/bin/kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && sudo chmod +x /usr/local/bin/kubectl

# trivy
# https://github.com/aquasecurity/trivy/releases
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sudo sh -s -- -b /usr/local/bin v0.37.3

# pack
# https://github.com/buildpacks/pack/releases
(curl -sSL "https://github.com/buildpacks/pack/releases/download/v0.28.0/pack-v0.28.0-linux.tgz" | sudo tar -C /usr/local/bin/ --no-same-owner -xzv pack)

# helm
# https://github.com/helm/helm/releases
(curl -sSL "https://get.helm.sh/helm-v3.11.1-linux-amd64.tar.gz" | sudo tar -C /usr/local/bin/ --no-same-owner --strip-components=1 -xzv linux-amd64/helm)

# skaffold
# https://github.com/GoogleContainerTools/skaffold/releases
sudo curl -Lo /usr/local/bin/skaffold https://storage.googleapis.com/skaffold/releases/v2.1.0/skaffold-linux-amd64 && sudo chmod +x /usr/local/bin/skaffold

# yq
# https://github.com/mikefarah/yq/releases
sudo curl -Lo /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/v4.30.8/yq_linux_amd64 && sudo chmod +x /usr/local/bin/yq

# yj
# https://github.com/sclevine/yj/releases
sudo curl -Lo /usr/local/bin/yj https://github.com/sclevine/yj/releases/download/v5.1.0/yj-linux-amd64 && sudo chmod +x /usr/local/bin/yj

# jq
# https://github.com/stedolan/jq/releases
sudo curl -Lo /usr/local/bin/jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 && sudo chmod +x /usr/local/bin/jq

# ytt
# https://github.com/vmware-tanzu/carvel-ytt/releases
sudo curl -Lo /usr/local/bin/ytt https://github.com/vmware-tanzu/carvel-ytt/releases/download/v0.44.3/ytt-linux-amd64 && sudo chmod +x /usr/local/bin/ytt

# kustomize
# https://github.com/kubernetes-sigs/kustomize/releases
(curl -sSL "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv5.0.0/kustomize_v5.0.0_linux_amd64.tar.gz" | sudo tar -C /usr/local/bin/ --no-same-owner -xzv kustomize)

# argocd
# https://github.com/argoproj/argo-cd/releases
sudo curl -Lo /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/v2.6.2/argocd-linux-amd64 && sudo chmod +x /usr/local/bin/argocd

# terraform
# https://releases.hashicorp.com/terraform
curl -Lo terraform.zip https://releases.hashicorp.com/terraform/1.3.9/terraform_1.3.9_linux_amd64.zip
unzip terraform.zip
chmod +x terraform
sudo mv terraform /usr/local/bin/terraform
rm terraform.zip

# starship
curl -fsSL https://starship.rs/install.sh | sudo sh -s -- '--yes'

# brew install nvm

# consul nomad vault envconsul consul-template
# hey
# ko crane
# k9s kubectx
# instrumenta/instrumenta/kubeval
# dty1er/tap/kubecolor
# cosign
