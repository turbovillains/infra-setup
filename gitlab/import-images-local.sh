#!/usr/bin/env bash

import_images() {
  local target_registry=${1:-${DOCKER_HUB:-cr.nrtn.dev}}

  declare -a images=(
    # "reg.com/namespace/image:tag@sha256:abcd:::k1=v1,k2=v2"
    "debian:${DEBIAN_VERSION:-11.0-slim}:::prepend_name=library/"
    "registry.k8s.io/kube-apiserver:${K8S_VERSION:-v1.23.5}:::prepend_name=kubernetes/"
    # "ubuntu:${UBUNTU_NOBLE_VERSION:-focal-20240212}"
    # "ubuntu:${UBUNTU_JAMMY_VERSION:-jammy-20220315}"
    # "ubuntu:${UBUNTU_FOCAL_VERSION:-focal-20210723}"
    # "alpine:${ALPINE_VERSION:-3.14.0}"
    # "busybox:${BUSYBOX_VERSION:-1.34.1}"
    # "gcr.io/distroless/static-${DISTROLESS_VERSION:-debian11}"
    # "gcr.io/distroless/base-${DISTROLESS_VERSION:-debian11}"
    # "gcr.io/distroless/java11-${DISTROLESS_VERSION:-debian11}"
    # "gcr.io/distroless/java17-${DISTROLESS_VERSION:-debian11}"
    # "gcr.io/distroless/cc-${DISTROLESS_VERSION:-debian11}"
    # "gcr.io/distroless/nodejs-${DISTROLESS_VERSION:-debian11}"
    # "buildpack-deps:${BUILDPACK_DEPS_BIONIC_VERSION:-bionic@sha256:1ae2e168c8cc4408fdf7cb40244643b99d10757f36391eee844834347de3c15c}"
    # "buildpack-deps:${BUILDPACK_DEPS_FOCAL_VERSION:-focal@sha256:eecbd661c4983df91059018d67c0d7203c68c1eeac036e6a479c3df94483ffba}"
    # "buildpack-deps:${BUILDPACK_DEPS_JAMMY_VERSION:-jammy@sha256:e93e88c6e97ffb6a315182db7d606dcb161714db7b2961a4efe727d39c165e1a}"
    # "php:${PHP_VERSION:-8.1.0-apache}"
  )

  for image_entry in "${images[@]}"; do
      image=$(strip_options ${image_entry})
      image_options=$(get_options ${image_entry})
      printf "\nMigrating %s/%s:%s to %s\n$(line)\n" \
          $(get_registry $image) $(get_name $image) $(get_tag $image) \
          ${target_registry}

      migrate_image "${image}" "${target_registry}" "${image_options}"
  done
}

export DEPLOY_ENVIRONMENT=local

_main() {
    set -eu
    local source_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
    source ${source_dir}/env.sh

    import_images
}

[[ "${BASH_SOURCE[0]}" != "${0}" ]] || _main "${@:-}"

# End of file
