#!/bin/bash
set +a
source <( yj -y < variables.yml | jq -r '.variables | to_entries[] | "\(.key)=\(.value)"' )
set -a
