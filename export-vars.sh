#!/bin/bash
# Export variables from variables.yml as environment variables for regsync

# Parse YAML and export variables
eval $(yq eval '.variables | to_entries | .[] | "export " + .key + "=\"" + .value + "\""' variables.yml)

# Set default target registry if not already set
export TARGET_REGISTRY="${TARGET_REGISTRY:-cr.noroutine.me}"

echo "Exported $(yq eval '.variables | length' variables.yml) variables from variables.yml"
echo "TARGET_REGISTRY=${TARGET_REGISTRY}"
