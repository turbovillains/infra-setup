#!/usr/bin/env bash -eux

curl -sLo- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash

cat << EOF | tee /root/.npmrc | tee /home/${BUILDER_USER}/.npmrc
registry=https://npm.lab03.noroutine.me/
strict-ssl=false
EOF

cat << EOF | tee /root/.yarnrc | tee /home/${BUILDER_USER}/.yarnrc
registry "https://npm.lab03.noroutine.me/"
strict-ssl false
EOF

sudo -H -u ${BUILDER_USER} bash -s <<'EOF'
curl -sLo- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "${NVM_DIR}/nvm.sh" ] && \. "${NVM_DIR}/nvm.sh"  # This loads nvm
nvm install stable
npm install -g npm yarn gatsby next nodeshift degit
EOF
