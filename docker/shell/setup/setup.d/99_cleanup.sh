#!/usr/bin/env bash -eux

# This should be last brew command in build process!
brew cleanup -s

chown -R ${BUILDER_USER}.users /home/${BUILDER_USER}
chmod +x /usr/local/bin/*

rm -rf /root/.cache /home/${BUILDER_USER}/.cache

rm -rf /home/linuxbrew/.cache \
  /home/linuxbrew/.linuxbrew/Homebrew/Library/Taps/*

apt-get clean && rm -rf /var/lib/apt/lists/*
rm /etc/apt/apt.conf.d/00proxy
