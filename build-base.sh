#!/usr/bin/env bash

set -euo pipefail

# Base Stage Build Script
# Depends on: scratch stage (noroutine-ca must be built and pushed first)

# Load variables from variables.yml (required for docker-compose)
if ! command -v yq &> /dev/null; then
  echo "Error: yq is required to load variables from variables.yml" >&2
  echo "Install with: brew install yq (macOS) or see https://github.com/mikefarah/yq" >&2
  exit 1
fi

echo "Loading variables from variables.yml..."
set +a
while IFS='=' read -r key value; do
  export "$key=$value"
done < <(yq eval '.variables | to_entries | .[] | .key + "=" + .value' variables.yml)
set -a
echo "Loaded $(yq eval '.variables | length' variables.yml) variables from variables.yml"

# Default values
IMAGE_REGISTRY=${IMAGE_REGISTRY:-cr.nrtn.dev}
INFRA_NAMESPACE=${INFRA_NAMESPACE:-infra-dev}
INFRA_VERSION=${INFRA_VERSION:-$(git rev-parse --short=8 HEAD 2>/dev/null || echo "dev")}
PUSH=${PUSH:-false}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --registry)
      IMAGE_REGISTRY="$2"
      shift 2
      ;;
    --namespace)
      INFRA_NAMESPACE="$2"
      shift 2
      ;;
    --version)
      INFRA_VERSION="$2"
      shift 2
      ;;
    --push)
      PUSH=true
      shift
      ;;
    --help)
      echo "Usage: $0 [options]"
      echo ""
      echo "Build base stage images (depends on scratch stage)"
      echo ""
      echo "Options:"
      echo "  --registry REGISTRY    Container registry (default: cr.nrtn.dev)"
      echo "  --namespace NAMESPACE  Image namespace (default: infra-dev)"
      echo "  --version VERSION      Image version tag (default: git short SHA or 'dev')"
      echo "  --push                 Push images after build (default: false)"
      echo "  --help                 Show this help message"
      echo ""
      echo "Environment variables:"
      echo "  IMAGE_REGISTRY    Override default registry"
      echo "  INFRA_NAMESPACE   Override default namespace"
      echo "  INFRA_VERSION     Override default version"
      echo "  PUSH              Set to 'true' to push images"
      echo ""
      echo "Prerequisites:"
      echo "  - scratch stage must be built and pushed first (noroutine-ca)"
      echo "  - Run: ./build-scratch.sh --push"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Run '$0 --help' for usage information"
      exit 1
      ;;
  esac
done

# Export basic variables for docker-compose
export IMAGE_REGISTRY
export INFRA_NAMESPACE
export INFRA_VERSION

echo ""
echo "Building BASE stage images..."
echo "  Registry:  ${IMAGE_REGISTRY}"
echo "  Namespace: ${INFRA_NAMESPACE}"
echo "  Version:   ${INFRA_VERSION}"
echo "  Push:      ${PUSH}"
echo ""
echo "Components: tools, debian, ubuntu24, alpine, noroutine-buoy, busybox,"
echo "            jdk-zulu, jdk-temurin, golang, python, python-slim"
echo ""

# Build arguments for docker buildx bake
BAKE_ARGS="-f docker-compose.base.yml"

if [[ "${PUSH}" == "true" ]]; then
  echo "Building and pushing multi-arch images..."
  docker buildx bake ${BAKE_ARGS} --push
else
  echo "Building images locally..."
  docker buildx bake ${BAKE_ARGS} --load
fi

echo ""
echo "Base stage build completed successfully!"
