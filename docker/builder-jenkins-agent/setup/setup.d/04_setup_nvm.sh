#!/usr/bin/env bash -eux

# cat << EOF | tee /home/${BUILDER_USER}/.npmrc
# registry=https://nexus.nrtn.dev/repository/npm/
# # strict-ssl=false
# EOF

# cat << EOF | tee /home/${BUILDER_USER}/.yarnrc
# registry "https://nexus.nrtn.dev/repository/npm/"
# # strict-ssl false
# EOF

sudo -H -u ${BUILDER_USER} bash -s <<'EOF'
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "${NVM_DIR}/nvm.sh" ] && source "${NVM_DIR}/nvm.sh"
[ -s "${NVM_DIR}/bash_completion" ] && source "${NVM_DIR}/bash_completion"

nvm install 'lts/*' --latest-npm
npm install -g npm yarn degit
EOF
