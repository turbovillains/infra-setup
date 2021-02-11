#!/usr/bin/env bash -eux

chown -R builder.users /home/builder

rm -rf /root/.cache /home/builder/.cache
apt-get clean && rm -rf /var/lib/apt/lists/*