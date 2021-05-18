#!/usr/bin/env bash -eux

chown -R ${BUILDER_USER}.users /home/${BUILDER_USER}

rm -rf /root/.cache /home/${BUILDER_USER}/.cache
apt-get clean && rm -rf /var/lib/apt/lists/*