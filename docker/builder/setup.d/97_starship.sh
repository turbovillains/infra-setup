#!/usr/bin/env bash -eux

curl -fsSL https://starship.rs/install.sh | sudo bash -s -- '--yes'

cat <<'EOF' | tee -a /root/.bashrc | tee -a /home/builder/.bashrc

# Starship
eval "$(starship init bash)"
EOF