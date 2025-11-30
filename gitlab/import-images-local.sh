#!/usr/bin/env bash

import_images() {
  local target_registry=${1:-${DOCKER_HUB:-cr.noroutine.me}}

  declare -a images=(
    # "reg.com/namespace/image:tag@sha256:abcd:::k1=v1,k2=v2"
    "debian:${DEBIAN_VERSION:-11.0-slim}"
    "registry.k8s.io/kube-apiserver:${K8S_VERSION:-v1.23.5}:::prepend_name=kubernetes/"
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
