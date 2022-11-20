#!/bin/bash

# kubectl
sudo curl -Lo /usr/local/bin/kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && sudo chmod +x /usr/local/bin/kubectl

# trivy
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sudo sh -s -- -b /usr/local/bin v0.18.3

# pack
(curl -sSL "https://github.com/buildpacks/pack/releases/download/v0.27.0/pack-v0.27.0-linux.tgz" | sudo tar -C /usr/local/bin/ --no-same-owner -xzv pack)

# helm
(curl -sSL "https://get.helm.sh/helm-v3.10.2-linux-amd64.tar.gz" | sudo tar -C /usr/local/bin/ --no-same-owner --strip-components=1 -xzv linux-amd64/helm)

# skaffold
sudo curl -Lo /usr/local/bin/skaffold https://storage.googleapis.com/skaffold/releases/v2.0.0/skaffold-linux-amd64 && sudo chmod +x /usr/local/bin/skaffold

# yq
sudo curl -Lo /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/v4.2.0/yq_linux_amd64 && sudo chmod +x /usr/local/bin/yq

# yj
sudo curl -Lo /usr/local/bin/yj https://github.com/sclevine/yj/releases/download/v5.1.0/yj-linux-amd64 && sudo chmod +x /usr/local/bin/yj

# jq
sudo curl -Lo /usr/local/bin/jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 && sudo chmod +x /usr/local/bin/jq

# ytt
sudo curl -Lo /usr/local/bin/ytt https://github.com/vmware-tanzu/carvel-ytt/releases/download/v0.43.0/ytt-linux-amd64 && sudo chmod +x /usr/local/bin/ytt

# kustomize
(curl -sSL "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv4.5.7/kustomize_v4.5.7_linux_amd64.tar.gz" | sudo tar -C /usr/local/bin/ --no-same-owner -xzv kustomize)

# argocd
sudo curl -Lo /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/v2.5.2/argocd-linux-amd64 && sudo chmod +x /usr/local/bin/argocd

# starship
curl -fsSL https://starship.rs/install.sh | sudo sh -s -- '--yes'

# consul nomad vault envconsul consul-template
# hey
# ko crane
# k9s kubectx
# instrumenta/instrumenta/kubeval
# dty1er/tap/kubecolor
