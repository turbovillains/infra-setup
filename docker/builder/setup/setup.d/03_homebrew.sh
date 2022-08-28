
export HOMEBREW_NO_ANALYTICS=1

# export HOMEBREW_BREW_GIT_REMOTE=https://readonly:${INFRA_READONLY_TOKEN}@git.nrtn.dev/infra/brew.git
# export HOMEBREW_CORE_GIT_REMOTE=https://readonly:${INFRA_READONLY_TOKEN}@git.nrtn.dev/infra/homebrew-core.git

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

brew tap vmware-tanzu/carvel

brew install \
  kubectl \
  helmfile \
  skaffold \
  cfssl \
  yq yj jq ytt \
  kustomize argocd \
  buildpacks/tap/pack \
  aquasecurity/trivy/trivy \
  terraform \
  cosign \
  skopeo \
  nvm

# consul nomad vault envconsul consul-template
# hey
# ko crane
# k9s kubectx
# instrumenta/instrumenta/kubeval
# dty1er/tap/kubecolor