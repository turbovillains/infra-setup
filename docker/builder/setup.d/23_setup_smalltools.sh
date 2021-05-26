#!/usr/bin/env bash -eux

# helmfile
curl -sLo /usr/local/bin/helmfile https://github.com/roboll/helmfile/releases/download/v0.138.7/helmfile_linux_amd64

# goreleaser
curl -sLO https://github.com/goreleaser/goreleaser/releases/download/v0.162.0/goreleaser_amd64.deb
shasum -a 256 goreleaser_amd64.deb | grep e5963c60c883d3ed08ab06612d9f640ff34770176fba825d6e94713b7099a561
dpkg -i goreleaser_amd64.deb
rm -f goreleaser_amd64.deb

# Crane
curl -sLo- https://github.com/google/go-containerregistry/releases/download/v0.5.1/go-containerregistry_Linux_x86_64.tar.gz | tar -C /usr/local/bin -zxv crane

# Ko
curl -sLo- https://github.com/google/ko/releases/download/v0.8.3/ko_0.8.3_Linux_x86_64.tar.gz | tar -C /usr/local/bin -zxv ko

# Kubeval
curl -sLo- https://github.com/instrumenta/kubeval/releases/latest/download/kubeval-linux-amd64.tar.gz | tar -C /usr/local/bin -zxv kubeval

# Skaffold
curl -sLo /usr/local/bin/skaffold https://storage.googleapis.com/skaffold/releases/v1.21.0/skaffold-linux-amd64

# cfssl
curl -sLo /usr/local/bin/cfssl https://github.com/cloudflare/cfssl/releases/download/v1.5.0/cfssl_1.5.0_linux_amd64

# yq
curl -sLo /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/v4.7.0/yq_linux_amd64
shasum -a 256 /usr/local/bin/yq | grep ec857c8240fda5782c3dd75b54b93196fa496a9bcf7c76979bb192b38f76da31

# yj
curl -sLo /usr/local/bin/yj https://github.com/sclevine/yj/releases/download/v5.0.0/yj-linux

# kpt
curl -sLo /usr/local/bin/kpt https://github.com/GoogleContainerTools/kpt/releases/download/v0.39.1/kpt_linux_amd64
shasum -a 256 /usr/local/bin/kpt | grep 7c8a6b92abd979621f955572a5ee5ddbba8a383b290dab121866b402a670aabf

# kustomize
curl -sLo kustomize.tar.gz https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv4.1.2/kustomize_v4.1.2_linux_amd64.tar.gz
shasum -a 256 kustomize.tar.gz | grep 4efb7d0dadba7fab5191c680fcb342c2b6f252f230019cf9cffd5e4b0cad1d12
tar zOxvf kustomize.tar.gz kustomize > /usr/local/bin/kustomize
rm kustomize.tar.gz

# kubecolor
curl -sLo kubecolor.tar.gz https://github.com/dty1er/kubecolor/releases/download/v0.0.12/kubecolor_0.0.12_Linux_x86_64.tar.gz
shasum -a 256 kubecolor.tar.gz | grep 3008b902c75e471c217c4b48d7804814d389f65b8c2849a6451e29e3a7a227b1
tar zOxvf kubecolor.tar.gz kubecolor > /usr/local/bin/kubecolor
rm kubecolor.tar.gz

# Pack
(curl -sSL "https://github.com/buildpacks/pack/releases/download/v0.18.1/pack-v0.18.1-linux.tgz" | sudo tar -C /usr/local/bin/ --no-same-owner -xzv pack)
mkdir -p /root/.pack /home/${BUILDER_USER}/.pack
cat <<EOF | tee /root/.pack/config.toml | tee /home/${BUILDER_USER}/.pack/config.toml
default-builder-image = "${DOCKER_HUB}/heroku/buildpacks:${BUILDPACKS_VERSION}"
lifecycle-image = "${DOCKER_HUB}/infra/buildpacksio-lifecycle:${BUILDPACKS_VERSION}"

[[trusted-builders]]
  name = "${DOCKER_HUB}/heroku/buildpacks:${BUILDPACKS_VERSION}"

[[trusted-builders]]
  name = "${DOCKER_HUB}/heroku/spring-boot-buildpacks:${BUILDPACKS_VERSION}"

[[trusted-builders]]
  name = "${DOCKER_HUB}/paketobuildpacks/builder:full"

[[trusted-builders]]
  name = "${DOCKER_HUB}/paketobuildpacks/builder:tiny"
EOF

# ttyd
curl -sLo /usr/local/bin/ttyd https://github.com/tsl0922/ttyd/releases/download/1.6.3/ttyd.x86_64

chmod +x /usr/local/bin/*