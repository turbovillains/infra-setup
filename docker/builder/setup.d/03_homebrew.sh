
export HOMEBREW_NO_ANALYTICS=1

export HOMEBREW_BREW_GIT_REMOTE=https://readonly:${INFRA_READONLY_TOKEN}@git.nrtn.dev/infra/brew.git
export HOMEBREW_CORE_GIT_REMOTE=https://readonly:${INFRA_READONLY_TOKEN}@git.nrtn.dev/infra/linuxbrew-core.git

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

brew install \
  go \
  kubectl \
  helm helmfile \
  goreleaser \
  skaffold \
  cfssl \
  yq yj jq \
  kustomize \
  buildpacks/tap/pack \
  terraform


# consul nomad vault envconsul consul-template
# hey
# ko crane
# k9s kubectx
# instrumenta/instrumenta/kubeval
# dty1er/tap/kubecolor