#!/bin/bash -eu

_main() {
    local source_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
    source ${source_dir}/env.sh

    # git clone --mirror git@github.com:Homebrew/homebrew-core.git homebrew-core
    # cd homebrew-core
    # git show-ref
    # git push --mirror --prune git@git.nrtn.dev:infra/homebrew-core.git

    git clone git@git.nrtn.dev:infra/homebrew-core.git homebrew-core
    cd homebrew-core
    git remote add upstream git@github.com:Homebrew/homebrew-core.git
    git pull --rebase upstream master
    git remote rm upstream
    git show-ref
    git push --mirror --force git@git.nrtn.dev:infra/homebrew-core.git

}

[[ "${BASH_SOURCE[0]}" != "${0}" ]] || _main "${@:-}"
