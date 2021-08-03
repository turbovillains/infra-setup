
export HOMEBREW_NO_ANALYTICS=1

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

brew tap GoogleContainerTools/kpt https://github.com/GoogleContainerTools/kpt.git

brew install \
  nvm \
  kubectl k9s kubectx \
  helm helmfile \
  goreleaser \
  crane \
  ko \
  instrumenta/instrumenta/kubeval \
  skaffold \
  cfssl \
  yq yj jq \
  kpt \
  kustomize \
  dty1er/tap/kubecolor \
  buildpacks/tap/pack \
  terraform consul nomad vault envconsul consul-template \
  govc \
  hey

  