#!/usr/bin/env bash -eux

cat << EOF | tee /root/.npmrc | tee /home/${BUILDER_USER}/.npmrc
registry=https://npm.lab03.noroutine.me/
strict-ssl=false
EOF

cat << EOF | tee /root/.yarnrc | tee /home/${BUILDER_USER}/.yarnrc
registry "https://npm.lab03.noroutine.me/"
strict-ssl false
EOF

sudo -H -u ${BUILDER_USER} bash -s <<'EOF'
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "/home/linuxbrew/.linuxbrew/opt/nvm/nvm.sh" ] && . "/home/linuxbrew/.linuxbrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/home/linuxbrew/.linuxbrew/opt/nvm/etc/bash_completion.d/nvm" ] && . "/home/linuxbrew/.linuxbrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

nvm install stable
npm install -g npm yarn degit
EOF
