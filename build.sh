#!/usr/bin/env bash

set -euo pipefail

# Unified Build Script for all stages
# Usage: ./build.sh [stage] [options]

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
    echo "Available stages: scratch, base, custom" >&2
    exit 1
  fi

  echo "Components in ${stage} stage:"
  echo ""

  # Export minimal variables needed for config parsing
  export IMAGE_REGISTRY="${IMAGE_REGISTRY:-cr.nrtn.dev}"
  export INFRA_NAMESPACE="${INFRA_NAMESPACE:-infra-dev}"
  export INFRA_VERSION="${INFRA_VERSION:-dev}"

  docker compose -f "$compose_file" config --services 2>/dev/null | while read service; do
    echo "  - $service"
  done
}

# Show help
show_help() {
  cat << EOF
Usage: $0 [stage] [options]

Build container images for different stages

Stages:
  scratch    Build scratch stage (noroutine-ca) - no dependencies
  base       Build base stage (debian, alpine, etc.) - depends on scratch
  custom     Build custom stage (airflow, argocd, etc.) - depends on base

  Default: scratch

Options:
  --registry REGISTRY      Container registry (default: cr.nrtn.dev)
  --namespace NAMESPACE    Image namespace (default: infra-dev)
  --version VERSION        Image version tag (default: git 8-char SHA or 'dev')
  --push                   Push images after build (default: false)
  --components COMP1,COMP2 Build only specific components (comma-separated)
  --list                   List available components for the stage
  --help                   Show this help message

Environment variables:
  IMAGE_REGISTRY    Override default registry
  INFRA_NAMESPACE   Override default namespace
  INFRA_VERSION     Override default version
  PUSH              Set to 'true' to push images

Examples:
  # Build all scratch stage images
  $0 scratch

  # Build all base stage images and push
  $0 base --push

  # Build specific custom components
  $0 custom --components airflow,grafana

  # List available components in base stage
  $0 base --list

  # Build with custom version
  $0 base --version v1.2.3 --push

Dependencies:
  scratch → base → custom

  Build stages in order and push before building the next stage:
    $0 scratch --push
    $0 base --push
    $0 custom --push

EOF
}

# Parse stage argument (first positional argument)
STAGE="scratch"
if [[ $# -gt 0 ]] && [[ ! "$1" =~ ^-- ]]; then
  STAGE="$1"
  shift
fi

# Validate stage
case "$STAGE" in
  scratch|base|custom)
    ;;
  *)
    echo "Error: Invalid stage '$STAGE'" >&2
    echo "Valid stages: scratch, base, custom" >&2
    echo "Run '$0 --help' for usage information" >&2
    exit 1
    ;;
esac

# Default values
IMAGE_REGISTRY=${IMAGE_REGISTRY:-cr.nrtn.dev}
INFRA_NAMESPACE=${INFRA_NAMESPACE:-infra-dev}
INFRA_VERSION=${INFRA_VERSION:-$(git rev-parse --short=8 HEAD 2>/dev/null || echo "dev")}
PUSH=${PUSH:-false}
COMPONENTS=""
LIST_ONLY=false

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

# Determine stage dependencies
case "$STAGE" in
  scratch)
    DEPENDENCIES="none"
    ;;
  base)
    DEPENDENCIES="scratch (noroutine-ca)"
    ;;
  custom)
    DEPENDENCIES="base (noroutine-ca, debian, alpine, etc.)"
    ;;
esac

echo ""
echo "Building ${STAGE^^} stage images..."
echo "  Registry:  ${IMAGE_REGISTRY}"
echo "  Namespace: ${INFRA_NAMESPACE}"
echo "  Version:   ${INFRA_VERSION}"
echo "  Push:      ${PUSH}"
if [[ -n "$COMPONENTS" ]]; then
  echo "  Components: ${COMPONENTS}"
else
  echo "  Components: all"
fi
echo ""
echo "Dependencies: ${DEPENDENCIES}"
echo ""

# Build arguments for docker buildx bake
BAKE_ARGS="-f ${COMPOSE_FILE}"

# Add component filter if specified
if [[ -n "$COMPONENTS" ]]; then
  # Convert comma-separated list to space-separated for docker compose
  COMPONENT_LIST=$(echo "$COMPONENTS" | tr ',' ' ')
  BAKE_ARGS="${BAKE_ARGS} ${COMPONENT_LIST}"
fi

if [[ "${PUSH}" == "true" ]]; then
  echo "Building and pushing multi-arch images..."
  docker buildx bake ${BAKE_ARGS} --push
else
  echo "Building images locally..."
  docker buildx bake ${BAKE_ARGS} --load
fi

echo ""
echo "${STAGE^} stage build completed successfully!"
echo ""

# Show next steps
case "$STAGE" in
  scratch)
    if [[ "${PUSH}" == "true" ]]; then
      echo "Next: Run './build.sh base --push' to build base stage"
    else
      echo "Note: Push scratch images before building base stage: './build.sh scratch --push'"
    fi
    ;;
  base)
    if [[ "${PUSH}" == "true" ]]; then
      echo "Next: Run './build.sh custom --push' to build custom stage"
    else
      echo "Note: Push base images before building custom stage: './build.sh base --push'"
    fi
    ;;
  custom)
    echo "All stages complete!"
    ;;
esac
echo ""
