
export HOMEBREW_NO_ANALYTICS=1

# export HOMEBREW_BREW_GIT_REMOTE=https://readonly:${INFRA_READONLY_TOKEN}@git.nrtn.dev/infra/brew.git
# export HOMEBREW_CORE_GIT_REMOTE=https://readonly:${INFRA_READONLY_TOKEN}@git.nrtn.dev/infra/homebrew-core.git

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

brew tap vmware-tanzu/carvel

# Avoid error with gcc
brew install gcc || true
brew postinstall gcc || true
brew doctor || true
brew reinstall gcc || true

brew install kubectl k9s
brew install helmfile
brew install skaffold
brew install cfssl
brew install yq yj jq ytt
brew install kustomize argocd
brew install hey
brew install skopeo

# consul nomad vault envconsul consul-template
# hey
# ko crane
# k9s kubectx
# instrumenta/instrumenta/kubeval
# dty1er/tap/kubecolor
