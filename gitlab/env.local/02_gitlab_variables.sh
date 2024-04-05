#!/usr/bin/env bash -eu

echo "Export GitLab variables"
set +a
# source <( yj -y < ${PROJECT_SOURCE_DIR}/variables.yml | jq -r '.variables | to_entries[] | "\(.key)=\(.value)"' )
source <( yj -y < ${PROJECT_SOURCE_DIR}/variables.yml | jq -r '.variables | to_entries[] | "export \(.key)=\(.value)"' )
set -a

# End of file
