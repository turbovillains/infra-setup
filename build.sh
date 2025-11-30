#!/usr/bin/env bash

set -euo pipefail

# Unified Build Script for all stages
# Usage: ./build.sh [stage] [options]

# Discover available stages from docker-compose.*.yml files
discover_stages() {
  local stages=()
  for file in docker-compose.*.yml; do
    if [[ -f "$file" ]]; then
      # Extract stage name from docker-compose.STAGE.yml
      stage="${file#docker-compose.}"
      stage="${stage%.yml}"
      stages+=("$stage")
    fi
  done
  echo "${stages[@]}"
}

# Load variables from variables.yml (required for docker-compose)
load_variables() {
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
}

# List available components for a stage
list_components() {
  local stage=$1
  local compose_file="docker-compose.${stage}.yml"

  if [[ ! -f "$compose_file" ]]; then
    echo "Error: Compose file not found: $compose_file" >&2
    echo "Available stages: $(discover_stages)" >&2
    exit 1
  fi

  echo "Components in ${stage} stage:"
  echo ""

  # Export minimal variables needed for config parsing
  export IMAGE_REGISTRY="${IMAGE_REGISTRY:-cr.noroutine.me}"
  export INFRA_NAMESPACE="${INFRA_NAMESPACE:-infra-dev}"
  export INFRA_VERSION="${INFRA_VERSION:-dev}"

  docker compose -f "$compose_file" config --services 2>/dev/null | while read service; do
    echo "  - $service"
  done
}

# Show help
show_help() {
  local available_stages=$(discover_stages)
  local first_stage=$(echo "$available_stages" | awk '{print $1}')

  cat << EOF
Usage: $0 [stage] [options]

Build container images for different stages

Stages:
  Available stages: ${available_stages}

  Default: ${first_stage}

Options:
  --registry REGISTRY      Container registry (default: cr.noroutine.me)
  --namespace NAMESPACE    Image namespace (default: infra-dev)
  --version VERSION        Image version tag (default: git 8-char SHA or 'dev')
  --push                   Push images after build (default: false)
  --components COMP1,COMP2 Build only specific components (comma-separated)
  --no-multiarch           Build for current platform only (faster, auto-enabled for non-tag builds)
  --multiarch              Force multiarch build even for non-tag builds
  --bake-args "ARGS"       Extra arguments to pass to docker buildx bake
  --list                   List available components for the stage
  --help                   Show this help message

Environment variables:
  IMAGE_REGISTRY    Override default registry
  INFRA_NAMESPACE   Override default namespace
  INFRA_VERSION     Override default version
  PUSH              Set to 'true' to push images

Examples:
  # Build all images for a stage (single-arch for speed on dev builds)
  $0 ${first_stage}

  # Build and push images
  $0 ${first_stage} --push

  # Build specific components
  $0 ${first_stage} --components component1,component2

  # List available components in a stage
  $0 ${first_stage} --list

  # Build with custom version tag (auto-enables multiarch)
  $0 ${first_stage} --version v1.2.3 --push

  # Force multiarch build for development
  $0 ${first_stage} --multiarch

  # Force single-arch build even for tags
  $0 ${first_stage} --version v1.0.0 --no-multiarch

  # Pass extra args to docker buildx bake
  $0 ${first_stage} --bake-args "--progress=plain"

EOF
}

# Get available stages
AVAILABLE_STAGES=($(discover_stages))

# Parse stage argument (first positional argument)
STAGE="${AVAILABLE_STAGES[0]}"
if [[ $# -gt 0 ]] && [[ ! "$1" =~ ^-- ]]; then
  STAGE="$1"
  shift
fi

# Validate stage
if [[ ! -f "docker-compose.${STAGE}.yml" ]]; then
  echo "Error: Invalid stage '$STAGE'" >&2
  echo "Available stages: ${AVAILABLE_STAGES[*]}" >&2
  echo "Run '$0 --help' for usage information" >&2
  exit 1
fi

# Default values
IMAGE_REGISTRY=${IMAGE_REGISTRY:-cr.noroutine.me}
INFRA_NAMESPACE=${INFRA_NAMESPACE:-infra-dev}
INFRA_VERSION=${INFRA_VERSION:-$(git rev-parse --short=8 HEAD 2>/dev/null || echo "dev")}
PUSH=${PUSH:-false}
COMPONENTS=""
LIST_ONLY=false
NO_MULTIARCH=""
FORCE_MULTIARCH=false
EXTRA_BAKE_ARGS=""

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
    --components)
      COMPONENTS="$2"
      shift 2
      ;;
    --list)
      LIST_ONLY=true
      shift
      ;;
    --no-multiarch)
      NO_MULTIARCH=true
      shift
      ;;
    --multiarch)
      FORCE_MULTIARCH=true
      shift
      ;;
    --bake-args)
      EXTRA_BAKE_ARGS="$2"
      shift 2
      ;;
    --help)
      show_help
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Run '$0 --help' for usage information"
      exit 1
      ;;
  esac
done

# Load variables if not listing
if [[ "$LIST_ONLY" == "false" ]]; then
  load_variables
fi

# Export basic variables for docker-compose
export IMAGE_REGISTRY
export INFRA_NAMESPACE
export INFRA_VERSION

# If --list, show components and exit
if [[ "$LIST_ONLY" == "true" ]]; then
  list_components "$STAGE"
  exit 0
fi

# Compose file for the stage
COMPOSE_FILE="docker-compose.${STAGE}.yml"

if [[ ! -f "$COMPOSE_FILE" ]]; then
  echo "Error: Compose file not found: $COMPOSE_FILE" >&2
  exit 1
fi

# Auto-detect tag builds: if version looks like a tag (starts with 'v' or is semver-like)
IS_TAG_BUILD=false
if [[ "$INFRA_VERSION" =~ ^v?[0-9]+\.[0-9]+\.[0-9]+ ]]; then
  IS_TAG_BUILD=true
fi

# Determine if we should use multiarch
USE_MULTIARCH=true
if [[ "$FORCE_MULTIARCH" == "true" ]]; then
  USE_MULTIARCH=true
elif [[ "$NO_MULTIARCH" == "true" ]]; then
  USE_MULTIARCH=false
elif [[ "$IS_TAG_BUILD" == "false" ]]; then
  # For non-tag builds, default to single-arch for speed
  USE_MULTIARCH=false
fi

# Detect current platform
CURRENT_ARCH=$(uname -m)
case "$CURRENT_ARCH" in
  x86_64)
    PLATFORM="linux/amd64"
    ;;
  aarch64|arm64)
    PLATFORM="linux/arm64"
    ;;
  *)
    PLATFORM="linux/$CURRENT_ARCH"
    ;;
esac

echo ""
echo "Building ${STAGE^^} stage images..."
echo "  Registry:  ${IMAGE_REGISTRY}"
echo "  Namespace: ${INFRA_NAMESPACE}"
echo "  Version:   ${INFRA_VERSION}"
echo "  Push:      ${PUSH}"
if [[ "$IS_TAG_BUILD" == "true" ]]; then
  echo "  Build Type: Tag build"
else
  echo "  Build Type: Development build"
fi
if [[ "$USE_MULTIARCH" == "true" ]]; then
  echo "  Platforms: Multi-arch (linux/amd64, linux/arm64)"
else
  echo "  Platforms: Single-arch ($PLATFORM)"
fi
if [[ -n "$COMPONENTS" ]]; then
  echo "  Components: ${COMPONENTS}"
else
  echo "  Components: all"
fi
echo ""

# Build arguments for docker buildx bake
BAKE_ARGS="-f ${COMPOSE_FILE}"

# Add platform override for single-arch builds
if [[ "$USE_MULTIARCH" == "false" ]]; then
  BAKE_ARGS="${BAKE_ARGS} --set *.platform=${PLATFORM}"
fi

# Add component filter if specified
if [[ -n "$COMPONENTS" ]]; then
  # Convert comma-separated list to space-separated for docker compose
  COMPONENT_LIST=$(echo "$COMPONENTS" | tr ',' ' ')
  BAKE_ARGS="${BAKE_ARGS} ${COMPONENT_LIST}"
fi

# Add extra bake args if specified
if [[ -n "$EXTRA_BAKE_ARGS" ]]; then
  BAKE_ARGS="${BAKE_ARGS} ${EXTRA_BAKE_ARGS}"
fi

if [[ "${PUSH}" == "true" ]]; then
  if [[ "$USE_MULTIARCH" == "true" ]]; then
    echo "Building and pushing multi-arch images..."
  else
    echo "Building and pushing single-arch image..."
  fi
  docker buildx bake ${BAKE_ARGS} --push
else
  echo "Building images locally..."
  docker buildx bake ${BAKE_ARGS} --load
fi

echo ""
echo "${STAGE^} stage build completed successfully!"
echo ""
