#!/usr/bin/env bash

set -euo pipefail

# Retag Script - Copy multi-arch images using crane
# For components that don't need rebuilding, just retagging

# Load variables from variables.yml
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

# List available components
list_components() {
  echo "Available components for retagging:"
  echo ""
  yq eval '.components | keys | .[]' components.yml | while read component; do
    echo "  - $component"
  done
  echo ""
  echo "Total: $(yq eval '.components | keys | length' components.yml) components"
}

# Show help
show_help() {
  cat << EOF
Usage: $0 [options]

Retag multi-arch container images using crane copy

This script copies images from their source registry to your target registry
without rebuilding them. Useful for images that are already multi-arch.

Options:
  --registry REGISTRY      Container registry (default: cr.nrtn.dev)
  --namespace NAMESPACE    Image namespace (default: infra-dev)
  --version VERSION        Image version tag (default: git 8-char SHA or 'dev')
  --components COMP1,COMP2 Retag only specific components (comma-separated)
  --list                   List available components
  --parallel N             Number of parallel retagging operations (default: 5)
  --dry-run                Show what would be done without executing
  --help                   Show this help message

Environment variables:
  IMAGE_REGISTRY    Override default registry
  INFRA_NAMESPACE   Override default namespace
  INFRA_VERSION     Override default version

Examples:
  # Retag all components
  $0

  # Retag specific components
  $0 --components redis,postgres,mongodb

  # Retag with custom version
  $0 --version v1.2.3

  # List available components
  $0 --list

  # Dry run to see what would be copied
  $0 --components redis --dry-run

Requirements:
  - crane (from go-containerregistry)
  - yq
  - variables.yml (for version variables)
  - components.yml (for component definitions)

EOF
}

# Default values
IMAGE_REGISTRY=${IMAGE_REGISTRY:-cr.nrtn.dev}
INFRA_NAMESPACE=${INFRA_NAMESPACE:-infra-dev}
INFRA_VERSION=${INFRA_VERSION:-$(git rev-parse --short=8 HEAD 2>/dev/null || echo "dev")}
COMPONENTS=""
LIST_ONLY=false
DRY_RUN=false
PARALLEL=5

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
    --components)
      COMPONENTS="$2"
      shift 2
      ;;
    --parallel)
      PARALLEL="$2"
      shift 2
      ;;
    --list)
      LIST_ONLY=true
      shift
      ;;
    --dry-run)
      DRY_RUN=true
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

# Check if crane is installed
if ! command -v crane &> /dev/null; then
  echo "Error: crane is required but not installed" >&2
  echo "Install from: https://github.com/google/go-containerregistry" >&2
  exit 1
fi

# If --list, show components and exit
if [[ "$LIST_ONLY" == "true" ]]; then
  list_components
  exit 0
fi

# Load variables
load_variables

# Export basic variables
export IMAGE_REGISTRY
export INFRA_NAMESPACE
export INFRA_VERSION

echo ""
echo "Retagging container images..."
echo "  Registry:  ${IMAGE_REGISTRY}"
echo "  Namespace: ${INFRA_NAMESPACE}"
echo "  Version:   ${INFRA_VERSION}"
echo "  Parallel:  ${PARALLEL}"
if [[ "$DRY_RUN" == "true" ]]; then
  echo "  Mode:      DRY RUN (no actual copies)"
fi
echo ""

# Determine which components to process
if [[ -n "$COMPONENTS" ]]; then
  COMPONENT_LIST=$(echo "$COMPONENTS" | tr ',' ' ')
else
  COMPONENT_LIST=$(yq eval '.components | keys | .[]' components.yml | tr '\n' ' ')
fi

# Function to retag a single component
retag_component() {
  local component=$1

  # Get component info from components.yml
  local image_base=$(yq eval ".components.${component}.image_base" components.yml)
  local image_version_expr=$(yq eval ".components.${component}.image_version" components.yml)

  if [[ "$image_base" == "null" ]] || [[ "$image_version_expr" == "null" ]]; then
    echo "  ✗ $component (not found in components.yml)"
    return 1
  fi

  # Expand the image_version expression (supports ${VAR} syntax)
  # This allows expressions like: ${STRIMZI_OPERATOR_VERSION}-kafka-${STRIMZI_KAFKA_VERSION}
  local image_version
  image_version=$(eval echo "$image_version_expr")

  # Construct source and destination
  local source="${IMAGE_REGISTRY}/${image_base}:${image_version}"
  local destination="${IMAGE_REGISTRY}/${INFRA_NAMESPACE}/${component}:${INFRA_VERSION}"

  if [[ "$DRY_RUN" == "true" ]]; then
    echo "  → $component"
    echo "    From: $source"
    echo "    To:   $destination"
    return 0
  fi

  # Use crane to copy (preserves all architectures and layers)
  if crane copy "$source" "$destination" 2>&1 | grep -q "error\|failed"; then
    echo "  ✗ $component (crane copy failed)"
    return 1
  else
    echo "  ✓ $component"
    return 0
  fi
}

# Export function for parallel execution
export -f retag_component
export IMAGE_REGISTRY INFRA_NAMESPACE INFRA_VERSION DRY_RUN

# Track failures
FAILED_COMPONENTS=()

# Process components in batches
TOTAL=$(echo $COMPONENT_LIST | wc -w | tr -d ' ')
CURRENT=0

echo "Processing $TOTAL components (${PARALLEL} at a time)..."
echo ""

# Convert to array for batching
COMPONENTS_ARRAY=($COMPONENT_LIST)
BATCH_SIZE=$PARALLEL

for ((i=0; i<${#COMPONENTS_ARRAY[@]}; i+=BATCH_SIZE)); do
  BATCH=("${COMPONENTS_ARRAY[@]:i:BATCH_SIZE}")
  BATCH_NUM=$((i/BATCH_SIZE + 1))
  TOTAL_BATCHES=$(( (TOTAL + BATCH_SIZE - 1) / BATCH_SIZE ))

  echo "Batch $BATCH_NUM/$TOTAL_BATCHES: ${BATCH[*]}"

  # Process batch in parallel
  for component in "${BATCH[@]}"; do
    retag_component "$component" &
  done

  # Wait for batch to complete
  wait

  CURRENT=$((CURRENT + ${#BATCH[@]}))
done

echo ""
echo "================================================"
echo "Retagging complete!"
echo ""
echo "Summary:"
echo "  Total components: $TOTAL"
echo "  Registry: ${IMAGE_REGISTRY}"
echo "  Namespace: ${INFRA_NAMESPACE}"
echo "  Version: ${INFRA_VERSION}"

if [[ "$DRY_RUN" == "true" ]]; then
  echo ""
  echo "This was a DRY RUN - no images were actually copied"
fi
