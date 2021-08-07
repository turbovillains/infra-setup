
export HOMEBREW_NO_ANALYTICS=1

export HOMEBREW_BREW_GIT_REMOTE=https://readonly:${INFRA_READONLY_TOKEN}@git.nrtn.dev/infra/brew.git
export HOMEBREW_CORE_GIT_REMOTE=https://readonly:${INFRA_READONLY_TOKEN}@git.nrtn.dev/infra/linuxbrew-core.git

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

brew install \
  kubectl k9s kubectx \
  helm helmfile \
  goreleaser \
  crane \
  ko \
  instrumenta/instrumenta/kubeval \
  skaffold \
  cfssl \
  yq yj jq \
  kustomize \
  dty1er/tap/kubecolor \
  buildpacks/tap/pack \
  terraform consul nomad vault envconsul consul-template \
  govc \
  hey

  