set +u
[[ -z ${GITLAB_CI} ]] || ( echo "Local only, failing"; exit 1 )
set -u
