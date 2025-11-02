#!/bin/bash

# Export all variables from variables.yml
# Usage: source ./export-variables.sh

set -euo pipefail

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
